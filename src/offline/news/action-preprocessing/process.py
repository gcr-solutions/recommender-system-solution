import argparse
import pickle

import boto3
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, size, row_number, expr, array_join
from pyspark.sql.types import StructType, StructField, StringType
from pyspark.sql.window import Window


def list_s3_by_prefix(bucket, prefix, filter_func=None):
    print(f"list_s3_by_prefix bucket: {bucket}, prefix: {prefix}")
    s3_bucket = boto3.resource('s3').Bucket(bucket)
    if filter_func is None:
        key_list = [s.key for s in s3_bucket.objects.filter(Prefix=prefix)]
    else:
        key_list = [s.key for s in s3_bucket.objects.filter(
            Prefix=prefix) if filter_func(s.key)]

    print("list_s3_by_prefix return:", key_list)
    return key_list


def s3_copy(bucket, from_key, to_key):
    s3_bucket = boto3.resource('s3').Bucket(bucket)
    copy_source = {
        'Bucket': bucket,
        'Key': from_key
    }
    s3_bucket.copy(copy_source, to_key)
    print("copied s3://{}/{} to s3://{}/{}".format(bucket, from_key, bucket, to_key))


parser = argparse.ArgumentParser(description="app inputs and outputs")
parser.add_argument("--bucket", type=str, help="s3 bucket")
parser.add_argument("--prefix", type=str,
                    help="s3 input key prefix")

args = parser.parse_args()

print("args:", args)
bucket = args.bucket
prefix = args.prefix
if prefix.endswith("/"):
    prefix = prefix[:-1]

print(f"bucket:{bucket}, prefix:{prefix}")

# input_prefix=recommender-system-news-open-toutiao/system/item-data/raw-input/
# output_prefix=recommender-system-news-open-toutiao/system/item-data/emr-out/

input_action_file = "s3://{}/{}/system/ingest-data/action/".format(bucket, prefix)
emr_action_output_key_prefix = "{}/system/emr/action-preprocessing/output/action".format(prefix)
emr_action_output_bucket_key_prefix = "s3://{}/{}".format(bucket, emr_action_output_key_prefix)
output_action_file_key = "{}/system/action-data/action.csv".format(prefix)

train_action_key_prefix = "{}/system/emr/action-preprocessing/output/train_action".format(prefix)
s3_train_action_key_prefix = "s3://{}/{}".format(bucket, train_action_key_prefix)
output_action_train_key = "{}/system/action-data/action_train.csv".format(prefix)

val_action_key_prefix = "{}/system/emr/action-preprocessing/output/val_action".format(prefix)
s3_val_action_key_prefix = "s3://{}/{}".format(bucket, train_action_key_prefix)
output_action_val_key = "{}/system/action-data/action_val.csv".format(prefix)

input_user_file = "s3://{}/{}/system/ingest-data/user/".format(bucket, prefix)
emr_user_output_key_prefix = "{}/system/emr/action-preprocessing/output/user".format(prefix)
emr_user_output_bucket_key_prefix = "s3://{}/{}".format(bucket, emr_user_output_key_prefix)
output_user_file_key = "{}/system/user-data/user.csv".format(prefix)

feat_dict_file = "s3://{}/{}/feature/content/inverted-list/news_id_news_feature_dict.pickle".format(bucket, prefix)

print("input_action_file:", input_action_file)


def gen_train_dataset(train_dataset_join):
    train_clicked_entities_words_arr_df = train_dataset_join.where(col("action_value") == 1).orderBy("timestamp_num") \
        .groupby('user_id').agg(expr("collect_list(entities) as entities_arr"),
                                expr("collect_list(entities) as words_arr"))

    train_entities_words_df = train_clicked_entities_words_arr_df.withColumn("clicked_entities",
                                                                             array_join(col('entities_arr'), "-")) \
        .withColumn("clicked_words", array_join(col('words_arr'), "-")).drop("entities_arr").drop("words_arr")

    # "user_id”, “news_words”, “news_entities”, “isclick”,
    # “clicked_words”, “clicked_entities”, “news_id”, ‘time_stamp’)

    train_dataset_final = train_dataset_join.join(train_entities_words_df, on=["user_id"]).select(
        "user_id", "words", "entities",
        "action_value", "clicked_words",
        "clicked_entities", "item_id", "timestamp")

    return train_dataset_final


def load_feature_dict(feat_dict_file):
    print("load_feature_dict:{}".format(feat_dict_file))
    with open(feat_dict_file, 'rb') as input:
        feat_dict = pickle.load(input)
    f_list = []
    for k, v in feat_dict.items():
        item_id = k
        entities = ",".join([str(it) for it in v['entities']])
        words = ",".join([str(it) for it in v['words']])
        f_list.append([item_id, entities, words])
    return f_list


feat_list = load_feature_dict(feat_dict_file)
print("feat_list len:{}".format(len(feat_list)))

with SparkSession.builder.appName("Spark App - action preprocessing").getOrCreate() as spark:
    #
    # process action file
    #
    print("start processing action file: {}".format(input_action_file))
    # 52a23654-9dc3-11eb-a364-acde48001122_!_6552302645908865543_!_1618455260_!_1_!_0
    df_action_input = spark.read.text(input_action_file)
    df_action_input = df_action_input.selectExpr("split(value, '_!_') as row").where(
        size(col("row")) > 4).selectExpr("row[0] as user_id",
                                         "row[1] as item_id",
                                         "row[2] as timestamp",
                                         "row[3] as action_type",
                                         "row[4] as action_value",
                                         )
    df_action_input.cache()
    df_action_input.coalesce(1).write.mode("overwrite").option(
        "header", "false").option("sep", "_!_").csv(emr_action_output_bucket_key_prefix)

    #
    # data for training
    #

    schema = StructType([
        StructField('item_id', StringType(), False),
        StructField('entities', StringType(), False),
        StructField('words', StringType(), False)
    ])
    df_feat = spark.createDataFrame(feat_list, schema)

    window_spec = Window.orderBy('timestamp')
    timestamp_num = row_number().over(window_spec)
    df_action_rank = df_action_input.withColumn("timestamp_num", timestamp_num)
    max_timestamp_num = df_action_rank.selectExpr("max(timestamp_num)").collect()[0]['max(timestamp_num)']
    max_train_num = int(max_timestamp_num * 0.7)

    train_dataset = df_action_rank.where(col('timestamp_num') <= max_train_num)
    val_dataset = df_action_rank.where(col('timestamp_num') > max_train_num)

    #
    # gen train dataset
    #
    train_dataset_join = train_dataset.join(df_feat, on=['item_id'])
    train_dataset_final = gen_train_dataset(train_dataset_join)
    train_dataset_final.coalesce(1).write.mode("overwrite").option(
        "header", "false").option("sep", "\t").csv(s3_train_action_key_prefix)

    # gen val dataset

    df_action_full = df_action_rank
    df_action_full_join = df_action_full.join(df_feat, on=['item_id'])
    val_user_df = val_dataset.select("user_id")
    val_dataset_full = df_action_full_join.join(val_user_df, on=["user_id"])
    val_dataset_final = gen_train_dataset(val_dataset_full)
    val_dataset_final.coalesce(1).write.mode("overwrite").option(
        "header", "false").option("sep", "\t").csv(s3_val_action_key_prefix)

    #
    # process user file
    #
    print("start processing user file: {}".format(input_user_file))
    df_user_input = spark.read.text(input_user_file)
    # 52a23654-9dc3-11eb-a364-acde48001122_!_M_!_47_!_1615956929_!_lyingDove7
    df_user_input = df_user_input.selectExpr("split(value, '_!_') as row").where(
        size(col("row")) > 4).selectExpr("row[0] as user_id",
                                         "row[1] as sex",
                                         "row[2] as age",
                                         "row[3] as timestamp",
                                         "row[4] as name",
                                         )
    df_user_input = df_user_input.dropDuplicates(['user_id'])
    df_user_input.coalesce(1).write.mode("overwrite").option(
        "header", "false").option("sep", "_!_").csv(emr_user_output_bucket_key_prefix)

emr_action_output_file_key = list_s3_by_prefix(
    bucket,
    emr_action_output_key_prefix,
    lambda key: key.endswith(".csv"))[0]
print("emr_action_output_file_key:", emr_action_output_file_key)
s3_copy(bucket, emr_action_output_file_key, output_action_file_key)
print("output_action_file_key:", output_action_file_key)

emr_user_output_file_key = list_s3_by_prefix(
    bucket,
    emr_user_output_key_prefix,
    lambda key: key.endswith(".csv"))[0]
print("emr_user_output_file_key:", emr_user_output_file_key)
s3_copy(bucket, emr_user_output_file_key, output_user_file_key)

print("output_user_file_key:", output_user_file_key)


train_action_key = list_s3_by_prefix(
    bucket,
    train_action_key_prefix,
    lambda key: key.endswith(".csv"))[0]
print("train_action_key:", train_action_key)
s3_copy(bucket, train_action_key, output_action_train_key)
print("output_action_train_key:", output_action_train_key)


val_action_key = list_s3_by_prefix(
    bucket,
    val_action_key_prefix,
    lambda key: key.endswith(".csv"))[0]
print("train_action_key:", train_action_key)
s3_copy(bucket, val_action_key, output_action_val_key)
print("output_action_val_key:", output_action_val_key)


print("All done")
