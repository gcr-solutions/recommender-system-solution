import time
import argparse
import boto3

from pyspark.sql import SparkSession
from pyspark.sql import Window
from pyspark.sql.functions import col, size, regexp_replace, trim
from pyspark.sql.functions import row_number, monotonically_increasing_id


def list_s3_by_prefix(bucket, prefix, filter_func=None):
    s3_bucket = boto3.resource('s3').Bucket(bucket)
    if filter_func is None:
        key_list = [s.key for s in s3_bucket.objects.filter(Prefix=prefix)]
    else:
        key_list = [s.key for s in s3_bucket.objects.filter(
            Prefix=prefix) if filter_func(s.key)]
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
parser.add_argument("--s3_bucket", type=str, help="s3 bucket")
parser.add_argument("--s3_input_key_prefix", type=str,
                    help="s3 input key prefix")
parser.add_argument("--s3_output_key_prefix", type=str,
                    help="s3 output key prefix")
args = parser.parse_args()

print("args:", args)

bucket = args.s3_bucket
out_prefix = args.s3_output_key_prefix
if out_prefix.endswith("/"):
    out_prefix = out_prefix[:-1]

input_file = "s3://{}/{}".format(bucket, args.s3_input_key_prefix)
emr_output_file = "s3://{}/{}/tmp-emr-out/".format(bucket, out_prefix)
output_file = "s3://{}/{}/item_map.csv".format(bucket, out_prefix)

print("input_file:", input_file)
print("emr_output_file:", emr_output_file)
print("output_file:", output_file)

with SparkSession.builder.appName("Gen item map").getOrCreate() as spark:
    # This is needed to save RDDs which is the only way to write nested Dataframes into CSV format
    # spark.sparkContext._jsc.hadoopConfiguration().set("mapred.output.committer.class",
    #                                                   "org.apache.hadoop.mapred.FileOutputCommitter")
    Timer1 = time.time()
    df_input = spark.read.text(input_file).selectExpr("split(value, '_!_') as row").where(
        size(col("row")) > 4).selectExpr("row[0] as id", "row[3] as item", "row[4] as keywords")
    df_no_null = df_input.where("keywords is not null").where(
        "keywords != ''").where("item is not null")
    df_rep = df_no_null.select(col("id"), regexp_replace(col(
        "item"), r'[&`><=@ω\{\}^#$/\]\[*【】Ⅴ；%+——「」｜…….:。\s？.：·、！《》!,，_~)）（(?“”"\\-]', '').alias('item_clean'))
    df_clean = df_rep.where(col('item_clean') != '').select(
        col("id"), col('item_clean'))
    df_index = df_clean.withColumn("index", row_number().over(
        Window.orderBy(monotonically_increasing_id())))
    df_final = df_index.select(col("index"), col("id"), col('item_clean'))
    df_final.coalesce(1).write.mode("overwrite").option(
        "header", "false").option("sep", "\t").csv(emr_output_file)
    print("It take {:.2f} mimutes to finish".format(
        (time.time() - Timer1) / 60))


emr_output_file_key = list_s3_by_prefix(
    bucket,
    emr_output_file,
    lambda key: key.endswith(".csv"))[0]

print("emr_output_file_key:", emr_output_file_key)

s3_copy(bucket, emr_output_file_key, output_file)

print("Done! outputfile:", output_file)
