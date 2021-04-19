from __future__ import print_function
import os
import sys
import math
import pickle
import boto3
import os
import numpy as np
import kg
import encoding
import pandas as pd
# from tqdm import tqdm
import time
import argparse
import logging
import re

# tqdm.pandas()
# pandarallel.initialize(progress_bar=True)
# bucket = os.environ.get("BUCKET_NAME", " ")
# raw_data_folder = os.environ.get("RAW_DATA", " ")

s3client = boto3.client('s3')

########################################
# 从s3同步数据
########################################
s3client = boto3.client('s3')


def sync_s3(file_name_list, s3_folder, local_folder):
    for f in file_name_list:
        print("file preparation: download src key {} to dst key {}".format(os.path.join(
            s3_folder, f), os.path.join(local_folder, f)))
        s3client.download_file(bucket, os.path.join(
            s3_folder, f), os.path.join(local_folder, f))


def write_to_s3(filename, bucket, key):
    print("upload s3://{}/{}".format(bucket, key))
    with open(filename, 'rb') as f:  # Read in binary mode
        # return s3client.upload_fileobj(f, bucket, key)
        return s3client.put_object(
            ACL='bucket-owner-full-control',
            Bucket=bucket,
            Key=key,
            Body=f
        )

def write_str_to_s3(content, bucket, key):
    print("write s3://{}/{}, content={}".format(bucket, key, content))
    s3client.put_object(Body=str(content).encode("utf8"), Bucket=bucket, Key=key, ACL='bucket-owner-full-control')

default_bucket = 'aws-gcr-rs-sol-workshop-ap-southeast-1-522244679887'
default_prefix = 'sample-data'
parser = argparse.ArgumentParser()
parser.add_argument('--bucket', type=str, default=default_bucket)
parser.add_argument('--prefix', type=str, default=default_prefix)
args, _ = parser.parse_known_args()
bucket = args.bucket
prefix = args.prefix

if prefix.endswith("/"):
    prefix = prefix[:-1]


print("bucket={}".format(bucket))
print("prefix='{}'".format(prefix))

meta_file_prefix = "{}/model/meta_files".format(prefix)

out_s3_path = "s3://{}/{}/feature/content/inverted-list".format(bucket, prefix)

local_folder = 'info'
if not os.path.exists(local_folder):
    os.makedirs(local_folder)
# 行为/物品数据同步
file_name_list = ['action.csv']
s3_folder = '{}/system/action-data'.format(prefix)
sync_s3(file_name_list, s3_folder, local_folder)
file_name_list = ['item.csv']
s3_folder = '{}/system/item-data'.format(prefix)
sync_s3(file_name_list, s3_folder, local_folder)

df_filter_item = pd.read_csv('info/item.csv',sep='_!_',names=['news_id','type_code','type','title','keywords','popularity','new'])

df_filter_action = pd.read_csv('info/action.csv',sep='_!_',names=['user_id','news_id','timestamp','action_type','action'])

df_item_stats = df_filter_action[['news_id','action_type','action']]
df_item_stats = df_item_stats.groupby(['news_id','action_type']).sum()
df_item_stats = df_item_stats.reset_index()
df_item_stats['action'] = df_item_stats['action'] / df_item_stats['action'].abs().max() * 10.0

pd_merge_result = pd.merge(df_filter_item, df_item_stats, on="news_id", how="left").drop(columns=['action_type'])
pd_merge_result = pd_merge_result.fillna(0)

# prepare model for batch process
os.environ['GRAPH_BUCKET'] = bucket
os.environ['KG_DBPEDIA_KEY'] = '{}/kg_dbpedia.txt'.format(meta_file_prefix)
os.environ['KG_ENTITY_KEY'] = '{}/entities_dbpedia.dict'.format(meta_file_prefix)
os.environ['KG_RELATION_KEY'] = '{}/relations_dbpedia.dict'.format(meta_file_prefix)
os.environ['KG_ENTITY_INDUSTRY_KEY'] = '{}/entity_industry.txt'.format(meta_file_prefix)
os.environ['KG_VOCAB_KEY'] = '{}/vocab.json'.format(meta_file_prefix)
os.environ['DATA_INPUT_KEY'] = ''
os.environ['TRAIN_OUTPUT_KEY'] = '{}/model/sort/content/kg/news/gw/'.format(prefix)

kg_path = os.environ['GRAPH_BUCKET']
dbpedia_key = os.environ['KG_DBPEDIA_KEY']
entity_key = os.environ['KG_ENTITY_KEY']
relation_key = os.environ['KG_RELATION_KEY']
entity_industry_key = os.environ['KG_ENTITY_INDUSTRY_KEY']
vocab_key = os.environ['KG_VOCAB_KEY']
data_input_key = os.environ['DATA_INPUT_KEY']
train_output_key = os.environ['TRAIN_OUTPUT_KEY']

env = {
    'GRAPH_BUCKET': kg_path,
    'KG_DBPEDIA_KEY': dbpedia_key,
    'KG_ENTITY_KEY': entity_key,
    'KG_RELATION_KEY': relation_key,
    'KG_ENTITY_INDUSTRY_KEY': entity_industry_key,
    'KG_VOCAB_KEY': vocab_key,
    'DATA_INPUT_KEY': data_input_key,
    'TRAIN_OUTPUT_KEY': train_output_key
}

print("Kg env: {}".format(env))
graph = kg.Kg(env)  # Where we keep the model when it's loaded
model = encoding.encoding(graph, env)

# generate dict_id_keywords for tfidf
dict_keywords_id = {}
for row in df_filter_item.iterrows():
    item_row = row[1]
    program_id = str(item_row['news_id'])
    for kw in item_row['keywords'].split(','):
        if kw not in dict_keywords_id.keys():
            dict_keywords_id[kw] = [program_id]
            continue
        current_list = dict_keywords_id[kw]
        current_list.append(program_id)
        dict_keywords_id[kw].append(program_id)
n_keyword_whole = len(dict_keywords_id)

def get_tfidf(category_property):
    if not category_property or str(category_property).lower() in ['nan', 'nr', '']:
        return [None]
    if not category_property:
        return [None]
    value = [item.strip() for item in category_property.split(',')]
    keywords_tfidf = {}
    for keyword in value:
        current_score = 1 / len(value)*math.log(n_keyword_whole / len(dict_keywords_id[keyword]))
        keywords_tfidf[keyword] = current_score
    return keywords_tfidf
        
def get_category(category_property):
    if not category_property or str(category_property).lower() in ['nan', 'nr', '']:
        return [None]
    if not category_property:
        return [None]
    return [item.strip().lower() for item in category_property.split(',')]
            
def get_single_item(item):
    if not item or str(item).lower().strip() in ['nan', 'nr', '']:
        return [None]
    return [str(item).lower().strip()]

def get_entities(title):
    return model[title]

def single_dict(raw_dict, feat, item_id):
    if feat not in raw_dict.keys():
        raw_dict[feat] = [item_id]
    else:
        current_list = raw_dict[feat]
        current_list.append(item_id)
        raw_dict[feat] = current_list

def list_dict(raw_dict, feat_list, item_id):
    for feat in feat_list:
        single_dict(raw_dict, feat, item_id)

def update_popularity(item_df, action_df):
    pd_merge_result = pd.merge(item_df, action_df, on="news_id", how="left").drop(columns=['action_type'])
    pd_merge_result = pd_merge_result.fillna(0)
    df_update = pd_merge_result.drop(columns=['popularity']).rename(columns={"action":"popularity"})
    df_update.loc[df_update.new == 1, 'popularity'] = 10.0
    df_update.loc[df_update.new == 1, 'new'] = 0
    return df_update
        
def sort_by_score(df):
    logging.info("sort_by_score() enter, df.columns: {}".format(df.columns))
    df['popularity'].fillna(0, inplace=True)

    df['popularity_log'] = np.log1p(df['popularity'])
    popularity_log_max = df['popularity_log'].max()
    popularity_log_min = df['popularity_log'].min()

    df['popularity_scaled'] = ((df['popularity_log'] - popularity_log_min) / (
            popularity_log_max - popularity_log_min)) * 10

    df_sorted = df.sort_values(by='popularity_scaled', ascending=False)
    
    df_sorted = df_sorted.drop(
        ['popularity_log', 'popularity_scaled'], axis=1)

    logging.info("sort_by_score() return, df.columns: {}".format(df_sorted.columns))
    return df_sorted

def get_bucket_key_from_s3_path(s3_path):
    m = re.match(r"s3://(.*?)/(.*)", s3_path)
    return m.group(1), m.group(2)

def gen_pickle_files(df, action_df):
    df_update = update_popularity(df, action_df)
    df_sort = sort_by_score(df_update)
    
    news_id_news_property_dict = {}
    news_type_news_ids_dict = {}
    news_keywords_news_ids_dict = {}
    news_entities_news_ids_dict = {}
    news_words_news_ids_dict = {}
    
    for row in df_sort.iterrows():
        item_row = row[1]
        program_id = str(item_row['news_id'])
        current_entities = get_entities(item_row['title'])[1]
        current_words = get_entities(item_row['title'])[0]
        program_dict = {
            'title': get_single_item(item_row['title']),
            'type': get_single_item(item_row['type']),
            'keywords': get_category(item_row['keywords']),
            'tfidf': get_tfidf(item_row['keywords']),
            'entities': current_entities,
            'words': current_words
        }
        news_id_news_property_dict[program_id] = program_dict
        list_dict(news_type_news_ids_dict, program_dict['type'], program_id)
        list_dict(news_keywords_news_ids_dict, program_dict['keywords'], program_id)
        list_dict(news_entities_news_ids_dict, program_dict['entities'], program_id)
        list_dict(news_words_news_ids_dict, program_dict['words'], program_id)

    result_dict = {
        'news_id_news_property_dict': news_id_news_property_dict,
        'news_type_news_ids_dict': news_type_news_ids_dict,
        'news_keywords_news_ids_dict': news_keywords_news_ids_dict,
        'news_entities_news_ids_dict': news_entities_news_ids_dict,
        'news_words_news_ids_dict': news_words_news_ids_dict
    }
    return result_dict

rd = gen_pickle_files(df_filter_item, df_item_stats)

bucket, out_prefix = get_bucket_key_from_s3_path(out_s3_path)
for dict_name, dict_val in rd.items():
    file_name = f'{dict_name}.pickle'
    # print("pickle =>", file_name)
    out_file = open(file_name, 'wb')
    pickle.dump(dict_val, out_file)
    out_file.close()
    # s3_url = S3Uploader.upload(file_name, out_s3_path)
    s3_url = write_to_s3(file_name, bucket, f'{out_prefix}/{file_name}')
    logging.info("write {}".format(s3_url))



