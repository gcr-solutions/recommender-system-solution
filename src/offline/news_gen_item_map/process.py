import time
from pyspark.sql import SparkSession
from pyspark.sql import Window
from pyspark.sql.functions import col, size, regexp_replace, trim
from pyspark.sql.functions import row_number, monotonically_increasing_id

BUCKET = "sagemaker-us-east-1-002224604296"
INPUT_KEY = "recommender-system-news-open-toutiao/system/item-data/emr-input/"
OUTPUT_KEY = "recommender-system-news-open-toutiao/system/item-data/emr-out/out.csv"

input_file = "s3://{}/{}".format(BUCKET, INPUT_KEY)
output_file = "s3://{}/{}".format(BUCKET, OUTPUT_KEY)

# tmp_dir = 'recommender-system-news-open-toutiao/system/item-data/tmp/'
# tmp_file = "s3://{}/{}/".format(bucket, tmp_dir)

with SparkSession.builder.appName("Gen item map").getOrCreate() as spark:
    Timer1 = time.time()
    df_input = spark.read.text(input_file).selectExpr("split(value, '_!_') as row").where(size(col("row")) > 4).selectExpr("row[0] as id", "row[3] as item", "row[4] as keywords")
    df_no_null = df_input.where("keywords is not null").where("keywords != ''").where("item is not null")
    df_rep = df_no_null.select(col("id"), regexp_replace(col("item"), r'[&`><=@ω\{\}^#$/\]\[*【】Ⅴ；%+——「」｜…….:。\s？.：·、！《》!,，_~)）（(?“”"\\-]', '').alias('item_clean'))
    df_clean = df_rep.where(col('item_clean') != '').select(col("id"), col('item_clean'))
    df_index = df_clean.withColumn("index", row_number().over(Window.orderBy(monotonically_increasing_id())))
    df_final = df_index.select(col("index"), col("id"), col('item_clean'))
    df_final.coalesce(1).write.mode("overwrite").option("header", "false").option("sep", "\t").csv(output_file)
    print("It take {:.2f} mimutes to finish".format((time.time() - Timer1) / 60))


# aws s3 cp  gen_item_map.py s3://sagemaker-us-east-1-002224604296/code/gen_item_map.py

# aws s3 --profile aoyu cp s3://sagemaker-us-east-1-002224604296/recommender-system-data/system/item-data/news/open-toutiao/toutiao_cat_data.txt  s3://sagemaker-us-east-1-002224604296/recommender-system-news-open-toutiao/system/item-data/raw-input/

