import time
import argparse
import boto3

from pyspark.sql import SparkSession
from pyspark.sql import Window
from pyspark.sql.functions import col, size, regexp_replace, trim
from pyspark.sql.functions import row_number, monotonically_increasing_id


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

input_file = "s3://{}/{}/system/ingest-data/action/".format(bucket, key_prefix)
emr_output_key_prefix = "{}/system/emr/action-preprocessing/output/".format(key_prefix)
emr_output_bucket_key_prefix = "s3://{}/{}".format(bucket, emr_output_key_prefix)

output_file_key = "{}/system/action-data/action.csv".format(key_prefix)

print("input_file:", input_file)
with SparkSession.builder.appName("Spark App - action preprocessing").getOrCreate() as spark:
    # This is needed to save RDDs which is the only way to write nested Dataframes into CSV format
    # spark.sparkContext._jsc.hadoopConfiguration().set("mapred.output.committer.class",
    #                                                   "org.apache.hadoop.mapred.FileOutputCommitter")
    Timer1 = time.time()

    df_input = spark.read.text(input_file)
    df_input.coalesce(1).write.mode("overwrite").option(
        "header", "false").option("sep", "\t").csv(emr_output_bucket_key_prefix)

    print("It take {:.2f} minutes to finish".format(
        (time.time() - Timer1) / 60))

emr_output_file_key = list_s3_by_prefix(
    bucket,
    emr_output_key_prefix,
    lambda key: key.endswith(".csv"))[0]

print("emr_output_file_key:", emr_output_file_key)
s3_copy(bucket, emr_output_file_key, output_file_key)
print("Done! output file:", output_file_key)
