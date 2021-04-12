import time
from pyspark import SparkContext, SparkConf
from pyspark.sql import SparkSession, Window
from pyspark.ml.feature import OneHotEncoder, StringIndexer
from pyspark.sql.types import StructType, StructField, StringType, IntegerType
from pyspark.sql.functions import to_timestamp, to_date, lit, sort_array, collect_list, col, udf
import pyspark.sql.functions as f

# import sys
# from awsglue.transforms import *
# from awsglue.utils import getResolvedOptions
# from pyspark.context import SparkContext
# from awsglue.context import GlueContext
# from awsglue.job import Job
# from awsglue.dynamicframe import DynamicFrame

import os
# import time
# from pyspark import SparkContext, SparkConf
# from pyspark.sql import SparkSession, Window
# from pyspark.ml.feature import OneHotEncoder, StringIndexer
# from pyspark.sql.types import StructType, StructField, StringType, IntegerType
# from pyspark.sql.functions import to_timestamp, to_date, lit, sort_array, collect_list, col, udf
# import pyspark.sql.functions as f

# #Retrieve parameters for the Glue job.
# args = getResolvedOptions(sys.argv, ['JOB_NAME', 'S3_SOURCE',
#                                      'RAW_DATA','NEWS_MAP_FOLDER',
#                                      'USER_MAP_FOLDER', 'NEWS_ENCODING_FOLDER',
#                                      'TRAIN_KEY', 'VAL_KEY'])

# sc = SparkContext()
# glueContext = GlueContext(sc)
# spark = glueContext.spark_session
# job = Job(glueContext)
# job.init(args['JOB_NAME'], args)


bucket = 'sagemaker-us-east-1-002224604296'
raw_data_folder = 'recsys_ml_pipeline/dkn_data/action_data_sample'
news_map_folder = 'recsys_ml_pipeline/model/news_map.csv'
user_map_folder = 'recsys_ml_pipeline/model/user_map.csv'
news_encoding_folder = 'recsys_ml_pipeline/model/news_encoding.csv'
train_folder = 'recsys_ml_pipeline/dkn_data/train.csv.sample'
val_folder = 'recsys_ml_pipeline/dkn_data/val.csv.sample'
                
args={}
args['S3_SOURCE'] = 's3://{}'.format(bucket)
args['RAW_DATA'] = raw_data_folder
args['NEWS_MAP_FOLDER'] = news_map_folder
args['USER_MAP_FOLDER'] = user_map_folder
args['NEWS_ENCODING_FOLDER'] = news_encoding_folder
args['TRAIN_KEY'] = train_folder
args['VAL_KEY'] = val_folder

# clean for second time, 
raw_data_path = os.path.join(args['S3_SOURCE'], args['RAW_DATA'])
news_map_path = os.path.join(args['S3_SOURCE'], args['NEWS_MAP_FOLDER'])
user_map_path = os.path.join(args['S3_SOURCE'], args['USER_MAP_FOLDER'])
news_encoding_path = os.path.join(args['S3_SOURCE'], args['NEWS_ENCODING_FOLDER'])
train_path = os.path.join(args['S3_SOURCE'], args['TRAIN_KEY'])
val_path = os.path.join(args['S3_SOURCE'], args['VAL_KEY'])

with SparkSession.builder.appName("My PyPi").getOrCreate() as spark:
    Timer1 = time.time()
    df_news_title_content_map = spark.read.format('csv').\
        options(header='true', inferSchema='false', encoding='utf8', escape="\"",sep='\t').\
        load(news_map_path)
    df_user_map = spark.read.format('csv').\
        options(header='true', inferSchema='false', encoding='utf8', escape="\"", sep='\t').\
        load(user_map_path)
    # df_news_title_content_map = spark.read.format('csv').\
    #     options(header='true', inferSchema='false', encoding='utf8', escape="\"",sep='\t').\
    #     load('s3://sagemaker-us-east-1-002224604296/bw-data-com-2/news_map.csv')
    # df_user_map = spark.read.format('csv').\
    #     options(header='true', inferSchema='false', encoding='utf8', escape="\"", sep='\t').\
    #     load('s3://sagemaker-us-east-1-002224604296/bw-data-com-2/user_map.csv')

    schema = StructType([
        StructField('user_str', StringType(), True),
        StructField('news_str', StringType(), True),
        StructField('news_title', StringType(), True),
        StructField('action', StringType(), True),
        StructField('date', StringType(), True),
    ]
    )

    dataDF = spark.read.format('csv').\
        options(header='false', inferSchema='false', encoding='utf8', escape="\"", sep='\001').\
        load(raw_data_path)

    # dataDF = spark.read.format('csv').\
    #     options(header='false', inferSchema='false', encoding='utf8', escape="\"", sep='\001').\
    #     load('s3://sagemaker-us-east-1-002224604296/bw-data-2/')

    df = spark.createDataFrame(data=dataDF.rdd, schema=schema)

    # df = df.filter(df.user_str != 'userid')
    df = df.filter(df.news_title != '')
    # df_click = df.filter(df.isclick == '1')

    # df.show()

    df = df.withColumn("time_stamp", to_timestamp(df.date, 'yyyy-MM-dd HH:mm:ss.SSSSSSSSS'))
    df = df.join(df_news_title_content_map.select('news_str', 'news_id'), on=['news_str'], how='left').\
        join(df_user_map, on=['user_str'], how='left').\
        select('user_id', 'news_id', 'news_title', 'action', 'time_stamp')

    # df.show()

    # last split
    filter_date = "2020-09-27 00:00:00.000000000"
    start_split_date = "2020-10-04 00:00:00.000000000"
    end_split_date = "2020-10-16 00:00:00.000000000"
    # end_train_val_split_date = "2020-10-14 00:00:00.000000000"
    # end_test_split_date = "2020-10-16 00:00:00"
    df = df.filter(df.time_stamp > filter_date)
    df_history = df.filter(df.time_stamp <= start_split_date)
    # df_history = df_history.filter(((df_history.action == 'recommend_article_click') | (df_history.action == 'recommend_article_read') | (df_history.action == 'recommend_article_comment') | (df_history.action == 'recommend_article_collect') | (df_history.action == 'recommend_article_share') | (df_history.action == 'recommend_article_favorite'))).select('user_id', 'news_id', 'news_title', 'time_stamp').withColumn('isclick', f.lit('1'))
    df_history = df_history.filter((df_history.action == 'recommend_article_click')).select('user_id', 'news_id', 'news_title', 'time_stamp').withColumn('isclick', f.lit('1'))


    df_data = df.filter(df.time_stamp > start_split_date)
    # df_data = df_data.withColumn('isclick', f.when(((f.col('action') == 'recommend_article_dislike') | (f.col('action') == 'recommend_article_exposure')) > 0, "0").\
    #     otherwise("1"))
    df_data = df_data.withColumn('isclick', f.when(f.col('action') == 'recommend_article_exposure', "0").\
        otherwise("1"))

    filter_count = 0
    df_history_click_sum = df_history.groupBy('user_id').agg(
        {'isclick': 'sum'}).withColumnRenamed('sum(isclick)', "sum_click")

    df_history_click_seed = df_history_click_sum.filter(
        df_history_click_sum.sum_click > filter_count)

    df_click_train = df_history.join(df_history_click_seed, df_history.user_id == df_history_click_seed.user_id, "inner").\
        select(df_history.user_id, df_history.news_id,
            df_history.isclick, df_history.time_stamp)

    # df_click_train.show()

    train_dataDF = spark.read.format('csv').\
        options(header='false', inferSchema='false', encoding='utf8', escape="\"", sep=',').\
        load(news_encoding_path)

    # train_dataDF = spark.read.format('csv').\
    #     options(header='false', inferSchema='false', encoding='utf8', escape="\"", sep=',').\
    #     load('s3://sagemaker-us-east-1-002224604296/bw-data-com-2/news_encoding.csv')

    schema = StructType([
        StructField('news_id', StringType(), True),
        StructField('news_str', StringType(), True),
        StructField('news_words', StringType(), True),
        StructField('news_entities', StringType(), True),
    ]
    )

    df_news_word_entity = spark.createDataFrame(
        data=train_dataDF.rdd, schema=schema)

    df_click_train = df_click_train.join(
        df_news_word_entity, on=['news_id'], how='left')

    # df_news_word_entity.filter(col('news_id')==37503).show()

    # df_click_train.filter(col('user_id')==837256).show()

    window = Window.partitionBy("user_id").orderBy(f.desc("time_stamp"))

    df_click = df_click_train \
        .withColumn("clicked_words_list", f.collect_list("news_words").over(window))\
        .withColumn("clicked_entities_list", f.collect_list("news_entities").over(window))\
        .select("user_id", "news_words", "news_entities", "isclick", "clicked_words_list", "clicked_entities_list")

    # df_click.filter(col('user_id')==837256).show()
    # df_click.show()

    df_click = df_click.groupby(df_click.user_id).agg(f.element_at(f.collect_list("clicked_words_list"), -1).alias("clicked_words"),
                                                    f.element_at(f.collect_list("clicked_entities_list"), -1).alias("clicked_entities"))

    df_click = df_user_map.join(df_click, on="user_id", how="left")

    df_click_history = df_click.select("user_id", f.concat_ws("-", f.col("clicked_words").cast("array<string>")).alias(
        "clicked_words"), f.concat_ws("-", f.col("clicked_entities").cast("array<string>")).alias("clicked_entities"))

    # construct
    df_data_with_history = df_data.alias("a").join(df_history_click_seed.alias('b'), df_data.user_id == df_history_click_seed.user_id, 'inner').\
        select('a.user_id', 'a.news_id', 'a.isclick', 'a.time_stamp')

    df_user = df_data_with_history.select(
        'user_id', 'news_id', 'isclick', 'time_stamp')

    df_user_with_word_entity = df_user.join(df_news_word_entity, on=['news_id'], how='left'). \
        select("user_id", "news_words", "news_entities",
            "isclick", "news_id", "time_stamp")

    df_complete = df_user_with_word_entity.join(df_click_history, on=['user_id'], how='left'). \
        select("user_id", "news_words", "news_entities", "isclick",
            "clicked_words", "clicked_entities", "news_id", 'time_stamp')

    df_train, df_test = df_complete.randomSplit([0.9, 0.1], 13)


    # df_train.show()

    # df_test.show()

    df_train.write.format('csv').\
        option('header', False).mode('overwrite').option('sep', '\t').\
        save(train_path)

    df_test.write.format('csv').\
        option('header', False).mode('overwrite').option('sep', '\t').\
        save(val_path)

    # df_train.write.format('csv').\
    #     option('header', False).mode('overwrite').option('sep', '\t').\
    #     save('s3://sagemaker-us-east-1-002224604296/bw-data-clean-2-complete-update-train-2-1.csv')

    # df_test.write.format('csv').\
    #     option('header', False).mode('overwrite').option('sep', '\t').\
    #     save('s3://sagemaker-us-east-1-002224604296/bw-data-clean-2-complete-update-test-2-1.csv')

    print("It take {:.2f} mimutes to finish".format((time.time()-Timer1)/60))
