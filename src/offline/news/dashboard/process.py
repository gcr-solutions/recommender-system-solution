import argparse
import json
import time

import boto3
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, size, expr, from_unixtime, to_timestamp, hour


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


def s3_upload(file, bucket, s3_key):
    s3_bucket = boto3.resource('s3').Bucket(bucket)
    s3_bucket.Object(s3_key).upload_file(file)
    print("uploaded file {} to s3://{}/{}".format(file, bucket, s3_key))


parser = argparse.ArgumentParser(description="app inputs and outputs")
parser.add_argument("--s3_bucket", type=str, help="s3 bucket")
parser.add_argument("--s3_key_prefix", type=str,
                    help="s3 input key prefix")

args = parser.parse_args()

print("args:", args)

bucket = args.s3_bucket
key_prefix = args.s3_key_prefix
if key_prefix.endswith("/"):
    input_prefix = key_prefix[:-1]

print(f"bucket:{bucket}, key_prefix:{key_prefix}")

# input_prefix=recommender-system-news-open-toutiao/system/item-data/raw-input/
# output_prefix=recommender-system-news-open-toutiao/system/item-data/emr-out/

item_input_file = "s3://{}/{}/system/ingest-data/item/".format(bucket, key_prefix)
action_input_file = "s3://{}/{}/system/ingest-data/action/".format(bucket, key_prefix)
user_input_file = "s3://{}/{}/system/user-data/".format(bucket, key_prefix)

output_file_key = "{}/system/dashboard/dashboard.json".format(key_prefix)

print("item_input_file:", item_input_file)
print("action_input_file:", action_input_file)
print("user_input_file:", user_input_file)

# item_input_file = '/Users/yonmzn/tmp/item/'
# action_input_file = '/Users/yonmzn/tmp/action/'
# user_input_file = '/Users/yonmzn/tmp/user/'

static_dict = {}


def item_static(df_item_input):
    print("item_static enter")
    global static_dict
    total_item_count = df_item_input.select("id").dropDuplicates(["id"]).count()
    is_new_count = df_item_input.selectExpr("id", "cast(is_new as int)").groupby("id").min("is_new").groupby(
        "min(is_new)").count().collect()
    static_dict["total_item_count"] = total_item_count
    for row in is_new_count:
        is_new, count = row['min(is_new)'], row['count']
        if is_new == 1:
            static_dict["new_item_count"] = count
            break
    print("item_static done")


def action_static(df_action_input, df_item_input, df_user_input):
    print("action_static enter")
    global static_dict
    df_item = df_item_input.select("id", "title_raw").dropDuplicates(["id"])
    df_item.cache()

    print("begin finding top_users ...")
    df_action_1 = df_action_input.where(col("action_value") == '1') \
        .withColumn("timestamp_bigint", expr("cast(timestamp as bigint)")). \
        withColumn("date_time",
                   to_timestamp(from_unixtime(col('timestamp_bigint'), 'yyyy-MM-dd HH:mm:ss'), 'yyyy-MM-dd HH:mm:ss')). \
        drop(col('timestamp_bigint')).drop(col('action_type')).drop(col('action_value')).drop(col('timestamp'))
    df_action_2 = df_action_1.withColumn('date', col('date_time').cast("date")) \
        .withColumn('hour', hour(col('date_time')))
    df_action_2.cache()

    join_type = "left_outer"
    df_action_2_with_user_name = df_action_2.groupby("user_id", "date", "hour") \
        .count().join(df_user_input, ['user_id'], join_type)

    df_action_3 = df_action_2_with_user_name.orderBy(
        [col("date").desc(), col("hour").desc(), col("count").desc()])
    user_rows = df_action_3.select(col("user_id"), col("user_name")).take(100)

    top_10_user_ids = []
    top_10_user = []
    for user in user_rows:
        user_id = user['user_id']
        user_name = user['user_name']
        if user_id not in top_10_user_ids:
            top_10_user_ids.append(user_id)
            top_10_user.append({
                'user_id': user_id,
                "name": user_name
            })
        if len(top_10_user_ids) >= 10:
            break

    static_dict['top_users'] = top_10_user

    print("begin finding top_items ...")
    item_click_count = df_action_2.groupby("item_id", "date", "hour").count()
    item_meta_df = df_item_input.select(col("id").alias("item_id"), col('title_raw'), col('item_type_code'), col('item_type'))
    item_meta_df.cache()

    df_item_click_sort = item_click_count.join(item_meta_df, ["item_id"], join_type).orderBy(
        [col("date").desc(), col("hour").desc(), col("count").desc()]).select(col("item_id"),
                                                                              col("title_raw").alias("title"))

    item_rows = df_item_click_sort.select(col("item_id"), col("title")).take(100)
    top_10_item_ids = []
    top_10_item = []
    for item_row in item_rows:
        item_id = item_row['item_id']
        title = item_row['title']
        if item_id not in top_10_item_ids:
            top_10_item_ids.append(item_id)
            top_10_item.append({
                "id": item_id,
                "title": title
            })
        if len(top_10_item_ids) >= 10:
            break

    static_dict['top_items'] = top_10_item


with SparkSession.builder.appName("Spark App - item preprocessing").getOrCreate() as spark:
    #
    # item data
    #
    df_item_input = spark.read.text(item_input_file)
    df_item_input = df_item_input.selectExpr("split(value, '_!_') as row").where(
        size(col("row")) > 6).selectExpr("row[0] as id",
                                         "row[1] as item_type_code",
                                         "row[2] as item_type",
                                         "row[3] as title_raw",
                                         "row[4] as keywords",
                                         "row[5] as popularity",
                                         "row[6] as is_new"
                                         )
    df_item_input.cache()
    print("df_item_input OK")

    #
    # action data
    #

    df_action_input = spark.read.text(action_input_file)
    df_action_input = df_action_input.selectExpr("split(value, '_!_') as row").where(
        size(col("row")) > 4).selectExpr("row[0] as user_id",
                                         "row[1] as item_id",
                                         "row[2] as timestamp",
                                         "row[3] as action_type",
                                         "row[4] as action_value",
                                         )
    df_action_input.cache()
    print("df_action_input OK")

    #
    # user data
    #
    df_user_input = spark.read.text(user_input_file)
    df_user_input = df_user_input.selectExpr("split(value, '_!_') as row").where(
        size(col("row")) > 4).selectExpr("row[0] as user_id",
                                         "row[4] as user_name",
                                         )
    print("df_user_input OK")
    df_user_input.cache()
    item_static(df_item_input)
    action_static(df_action_input, df_item_input, df_user_input)


print("static_dict:", static_dict)
file_name = "dashboard.json"
with open(file_name, 'w') as out:
    json.dump(static_dict, out, indent=1)

s3_upload(file_name, bucket, output_file_key)
print("Done!")
