#!/usr/bin/env python

# Copyright 2017-2018 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You
# may not use this file except in compliance with the License. A copy of
# the License is located at
#
#     http://aws.amazon.com/apache2.0/
#
# or in the "license" file accompanying this file. This file is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
# ANY KIND, either express or implied. See the License for the specific
# language governing permissions and limitations under the License.

# This file implements the hosting solution, which just starts TensorFlow Model Serving.
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
from tqdm import tqdm
import time
import faiss
import argparse

tqdm.pandas()
# pandarallel.initialize(progress_bar=True)
# bucket = os.environ.get("BUCKET_NAME", " ")
# raw_data_folder = os.environ.get("RAW_DATA", " ")

s3client = boto3.client('s3')


def batch_process(bucket, key_prefix):
    ########################################
    # sync info fodler from s3
    ########################################
    print("!!!load raw data!!!")
    local_folder = 'data_source'
    # load raw data
    file_name_list = ['toutiao_cat_data.txt']
    s3_folder = '{}/system/item-data/raw-input/'.format(key_prefix)

    if not os.path.exists(local_folder):
        os.makedirs(local_folder)
    for f in file_name_list:
        print("data preparation: download src key {} to dst key {}".format(os.path.join(
            s3_folder, f), os.path.join(local_folder, f)))
        s3client.download_file(bucket, os.path.join(
            s3_folder, f), os.path.join(local_folder, f))
    raw_data_path = os.path.join(local_folder, file_name_list[0])
    # load item map data
    file_name_list = ['item_map.csv']
    s3_folder = '{}/system/item-data/emr-out/'.format(key_prefix)
    if not os.path.exists(local_folder):
        os.makedirs(local_folder)
    for f in file_name_list:
        print("data preparation: download src key {} to dst key {}".format(os.path.join(
            s3_folder, f), os.path.join(local_folder, f)))
        s3client.download_file(bucket, os.path.join(
            s3_folder, f), os.path.join(local_folder, f))
    item_map_path = os.path.join(local_folder, file_name_list[0])
    # load word embedding data
    file_name_list = ['dkn_word_embedding.npy']
    s3_folder = '{}/model/sort/content/words/sgns-mixed-large/'.format(key_prefix)
    if not os.path.exists(local_folder):
        os.makedirs(local_folder)
    for f in file_name_list:
        print("data preparation: download src key {} to dst key {}".format(os.path.join(
            s3_folder, f), os.path.join(local_folder, f)))
        s3client.download_file(bucket, os.path.join(
            s3_folder, f), os.path.join(local_folder, f))
    news_word_embed_path = os.path.join(local_folder, file_name_list[0])
    # load entity embedding data
    file_name_list = ['dkn_entity_embedding.npy']
    s3_folder = '{}/model/sort/content/kg/'.format(key_prefix)
    if not os.path.exists(local_folder):
        os.makedirs(local_folder)
    for f in file_name_list:
        print("data preparation: download src key {} to dst key {}".format(os.path.join(
            s3_folder, f), os.path.join(local_folder, f)))
        s3client.download_file(bucket, os.path.join(
            s3_folder, f), os.path.join(local_folder, f))
    news_entity_embed_path = os.path.join(local_folder, file_name_list[0])
    # prepare model for batch process
    os.environ['GRAPH_BUCKET'] = bucket
    os.environ['KG_DBPEDIA_KEY'] = '{}/model/sort/content/words/mapping/kg_dbpedia.txt'.format(key_prefix)
    os.environ['KG_ENTITY_KEY'] = '{}/model/sort/content/words/mapping/entities_dbpedia.dict'.format(key_prefix)
    os.environ['KG_RELATION_KEY'] = '{}/model/sort/content/words/mapping/relations_dbpedia.dict'.format(key_prefix)
    os.environ['KG_ENTITY_INDUSTRY_KEY'] = '{}/model/sort/content/words/mapping/entity_industry.txt'.format(key_prefix)
    os.environ['KG_VOCAB_KEY'] = '{}/model/sort/content/words/mapping/vocab.json'.format(key_prefix)
    os.environ['DATA_INPUT_KEY'] = ''
    os.environ['TRAIN_OUTPUT_KEY'] = '{}/model/sort/content/kg/news/gw/'.format(key_prefix)
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

    print("Kg env:", env)
    graph = kg.Kg(env)  # Where we keep the model when it's loaded
    model = encoding.encoding(graph, env)
    ########################################
    # load data and clean
    ########################################
    print("!!!clean data!!!")
    reader = open(raw_data_path, encoding='utf8')
    filter_news = []
    n_rows = 0
    for line in reader:
        array = line.strip().split('_!_')
        if array[-1] != '' and array[-2] != '':
            local_list = []
            local_list.append(array[0])
            local_list.append(array[1])
            local_list.append(array[2])
            local_list.append(array[3])
            local_list.append(array[4])
            filter_news.append(local_list)
        n_rows = n_rows + 1
    df_filter_news = pd.DataFrame(
        filter_news, columns=['news_id', 'code', 'news_type', 'news_title', 'keywords'])
    print("before filter {} news, after filter {} news".format(
        n_rows, len(filter_news)))
    ########################################
    # generate batch data
    ########################################
    print("!!!start batch!!!")
    save_folder = './info'
    pickle_batch_file_list = []
    if not os.path.exists(save_folder):
        os.makedirs(save_folder)
    # dict: news_id <-> news_title
    pickle_batch_file_list.append('news_id_news_title_dict.pickle')
    df_id_title = df_filter_news[['news_id', 'news_title']]
    dict_id_title = df_id_title.set_index('news_id')['news_title'].to_dict()
    save_local_path = os.path.join(save_folder, pickle_batch_file_list[-1])
    file_to_write = open(save_local_path, "wb")
    pickle.dump(dict_id_title, file_to_write)
    print("finish dump {} to {}".format(
        pickle_batch_file_list[-1], save_local_path))
    # dict: news_id <-> news_type
    pickle_batch_file_list.append('news_id_news_type_dict.pickle')
    df_id_type = df_filter_news[['news_id', 'news_type']]
    dict_id_type = df_id_type.set_index('news_id')['news_type'].to_dict()
    save_local_path = os.path.join(save_folder, pickle_batch_file_list[-1])
    file_to_write = open(save_local_path, "wb")
    pickle.dump(dict_id_type, file_to_write)
    print("finish dump {} to {}".format(
        pickle_batch_file_list[-1], save_local_path))
    # dict: news_type <-> news_id
    pickle_batch_file_list.append('news_type_news_ids_dict.pickle')
    df_type_id = df_filter_news[['news_id', 'news_type']]
    dict_type_id = df_type_id.groupby(
        'news_type')['news_id'].apply(list).to_dict()
    save_local_path = os.path.join(save_folder, pickle_batch_file_list[-1])
    file_to_write = open(save_local_path, "wb")
    pickle.dump(dict_type_id, file_to_write)
    print("finish dump {} to {}".format(
        pickle_batch_file_list[-1], save_local_path))
    # dict: news_id <-> keywords
    pickle_batch_file_list.append('news_id_keywords_dict.pickle')
    df_id_keywords = df_filter_news[['news_id', 'keywords']]
    dict_id_keywords = df_id_keywords.set_index('news_id')['keywords'].to_dict()
    save_local_path = os.path.join(save_folder, pickle_batch_file_list[-1])
    file_to_write = open(save_local_path, "wb")
    pickle.dump(dict_id_keywords, file_to_write)
    print("finish dump {} to {}".format(
        pickle_batch_file_list[-1], save_local_path))
    # dict: keywords <-> news_id
    pickle_batch_file_list.append('keywords_news_ids_dict.pickle')
    reader = open(raw_data_path, encoding='utf8')
    dict_keywords_id = {}
    n_rows = 0
    for line in reader:
        array = line.strip().split('_!_')
        if array[-1] != '':
            keywords_list = array[-1].split(',')
            for keywords in keywords_list:
                if keywords in dict_keywords_id:
                    dict_keywords_id[keywords].append(array[0])
                else:
                    dict_keywords_id[keywords] = [array[0]]
        n_rows = n_rows + 1
    save_local_path = os.path.join(save_folder, pickle_batch_file_list[-1])
    file_to_write = open(save_local_path, "wb")
    pickle.dump(dict_keywords_id, file_to_write)
    print("finish dump {} to {}".format(
        pickle_batch_file_list[-1], save_local_path))
    # dict: news_id <-> entity_index
    # dict: news_id <-> word_index
    map_pddf = pd.read_csv(item_map_path, quoting=3, header=None, sep='\t', names=[
                           'news_no', 'news_id', 'news_title'])
    
    # map_pddf = df_filter_news[['news_id', 'news_title']]
    sample_pddf = map_pddf
    # sample_pddf['idx'] = sample_pddf['news_title']
    print("whole length of news is {}".format(len(sample_pddf)))
    # for ind in map_pddf.index:
    #     try:
    #         sample_pddf['idx'][ind] = model[sample_pddf['news_title'][ind]]
    #     except Exception as e:
    #         print("error {} is {}".format(e, sample_pddf['news_title'][ind]))
    print("start model")
    sample_pddf['idx'] = sample_pddf['news_title'].progress_apply(lambda x: list(model[x]))
    # sample_pddf.to_csv('./result.csv',header=False)
    print("finish model")
    sample_pddf['num_word_idx'] = sample_pddf['idx'].apply(lambda x: x[0])
    sample_pddf['num_entity_idx'] = sample_pddf['idx'].apply(lambda x: x[1])
    sample_pddf['str_word_idx'] = sample_pddf['idx'].apply(lambda x: str(x[0]).replace('[','').replace(']','').replace(' ',''))
    sample_pddf['str_entity_idx'] = sample_pddf['idx'].apply(lambda x: str(x[1]).replace('[','').replace(']','').replace(' ',''))

    #sample_pddf['num_word_idx'] = sample_pddf['idx'].apply(lambda x: list(map(int, x.replace('[','').replace(']','').split(',')[0:16])))
    #sample_pddf['num_entity_idx'] = sample_pddf['idx'].apply(lambda x: list(map(int, x.replace('[','').replace(']','').split(',')[16:])))
    #sample_pddf['str_word_idx'] = sample_pddf['idx'].apply(lambda x: x.replace('[','').replace(']','').split(',')[0:16])
    #sample_pddf['str_entity_idx'] = sample_pddf['idx'].apply(lambda x: x.replace('[','').replace(']','').split(',')[16:])
    # prepare news_encoding
    word_embed_value = np.load(news_word_embed_path)
    entity_embed_value = np.load(news_entity_embed_path)
    # # dict: word_index <-> news_id
    # file_to_load = open("news_id_word_index_map.pickle", "rb")
    # dict_id_word = pickle.load(file_to_load)
    # print("length of news_id v.s. word_id {}".format(len(dict_id_word)))
    n = 0
    id_word_dict = {}
    id_entity_dict = {}
    local_start = time.time()
    for key, value in dict_id_title.items():
        n = n+1
        local_end = time.time()
        if (n)%5000 == 0:
            print("prcessed 5000 for {} hour".format((local_end-local_start)/3600))
            local_start = time.time()
        try:
            word_entity_result = []
            word_entity_result.append(sample_pddf[sample_pddf['news_id']==int(key)]['num_word_idx'].values[0])
            word_entity_result.append(sample_pddf[sample_pddf['news_id']==int(key)]['num_entity_idx'].values[0])
            for word_index in word_entity_result[0]:
                if word_index != 0:
                    test = word_embed_value[word_index]
            for entity_index in word_entity_result[1]:
                if entity_index != 0:
                    test = entity_embed_value[entity_index]
            id_word_dict[key] = word_entity_result[0]
            id_entity_dict[key] = word_entity_result[1]
        except Exception as e:
            print("errer {} with title {}".format(e, value))
            break
    pickle_batch_file_list.append('news_id_word_ids_dict.pickle')
    save_local_path = os.path.join(save_folder, pickle_batch_file_list[-1])
    file_to_write = open(save_local_path, "wb")
    pickle.dump(id_word_dict, file_to_write)
    print("finish dump {} to {}".format(
        pickle_batch_file_list[-1], save_local_path))
    pickle_batch_file_list.append('news_id_entity_ids_dict.pickle')
    save_local_path = os.path.join(save_folder, pickle_batch_file_list[-1])
    file_to_write = open(save_local_path, "wb")
    pickle.dump(id_entity_dict, file_to_write)
    print("finish dump {} to {}".format(
        pickle_batch_file_list[-1], save_local_path))
    word_id_dict = {}
    for key, values in id_word_dict.items():
        for value in values:
            if value != 0:
                if value not in word_id_dict:
                    word_id_dict[value] = [key]
                else:
                    llist = word_id_dict[value]
                    if key not in llist:
                        llist.append(key)
                        word_id_dict[value] = llist
    pickle_batch_file_list.append('word_id_news_ids_dict.pickle')
    save_local_path = os.path.join(save_folder, pickle_batch_file_list[-1])
    file_to_write = open(save_local_path, "wb")
    pickle.dump(word_id_dict, file_to_write)
    print("finish dump {} to {}".format(
        pickle_batch_file_list[-1], save_local_path))
    # dict: entity_index <-> news_id
    entity_id_dict = {}
    for key, values in id_entity_dict.items():
        for value in values:
            if value != 0:
                if value not in entity_id_dict:
                    entity_id_dict[value] = [key]
                else:
                    llist = entity_id_dict[value]
                    if key not in llist:
                        llist.append(key)
                        entity_id_dict[value] = llist
    pickle_batch_file_list.append('entity_id_news_ids_dict.pickle')
    save_local_path = os.path.join(save_folder, pickle_batch_file_list[-1])
    file_to_write = open(save_local_path, "wb")
    pickle.dump(entity_id_dict, file_to_write)
    print("finish dump {} to {}".format(
        pickle_batch_file_list[-1], save_local_path))
    # dict: news_id <-> keywords <-> tfidf score
    pickle_batch_file_list.append('news_id_keywords_tfidf_dict.pickle')
    n_keyword_whole = len(dict_keywords_id)
    dict_id_keywords_tfidf = {}
    n_debug_check = 0
    for key, value in dict_id_keywords.items():
        keywords_tfidf = {}
    #     print("current key {} with value {}".format(key, value))
        for keyword in value.split(','):
            current_score = 1 / \
                len(value.split(','))*math.log(n_keyword_whole /
                                               len(dict_keywords_id[keyword]))
            keywords_tfidf[keyword] = current_score
        dict_id_keywords_tfidf[key] = keywords_tfidf
    save_local_path = os.path.join(save_folder, pickle_batch_file_list[-1])
    file_to_write = open(save_local_path, "wb")
    pickle.dump(dict_id_keywords_tfidf, file_to_write)
    print("finish dump {} to {}".format(
        pickle_batch_file_list[-1], save_local_path))
    ########################################
    # generate item encoding
    ########################################
    encoding_batch_file_list = []
    encoding_batch_file_list.append('news_encoding.csv')
    save_local_path = os.path.join(save_folder, encoding_batch_file_list[-1])
    news_encoding_pddf = sample_pddf[['news_no', 'news_id', 'str_word_idx', 'str_entity_idx']]
    news_encoding_pddf.to_csv(save_local_path, header=False)
    print("finish dump {} to {}".format(
       encoding_batch_file_list[-1], save_local_path))
    ########################################
    # generate index data
    ########################################
    entity_dimension = 128
    word_dimension = 300
    X_train_entity = np.load(news_entity_embed_path)
    X_train_word = np.load(news_word_embed_path)
    n = X_train_entity.shape[0]
    nlist = 5
    entity_quantiser = faiss.IndexFlatL2(entity_dimension)
    word_quantiser = faiss.IndexFlatL2(word_dimension)
    entity_index = faiss.IndexIVFFlat(entity_quantiser, entity_dimension, nlist,   faiss.METRIC_L2)
    word_index = faiss.IndexIVFFlat(word_quantiser, word_dimension, nlist,   faiss.METRIC_L2)
    train_entity_nd_array = X_train_entity.astype('float32')
    train_word_nd_array = X_train_word.astype('float32')

    index_batch_file_list = []
    index_batch_file_list.append('recommender-system-news-toutiao-entity-vector.index')
    entity_index.train(train_entity_nd_array)
    entity_index.add(train_entity_nd_array)
    save_local_path = os.path.join(save_folder, index_batch_file_list[-1])
    faiss.write_index(entity_index, save_local_path)
    print("finish dump {} to {}".format(
       index_batch_file_list[-1], save_local_path))
    index_batch_file_list = []
    index_batch_file_list.append('recommender-system-news-toutiao-word-vector.index')
    word_index.train(train_word_nd_array)
    word_index.add(train_word_nd_array)
    save_local_path = os.path.join(save_folder, index_batch_file_list[-1])
    faiss.write_index(word_index, save_local_path)
    print("finish dump {} to {}".format(
       index_batch_file_list[-1], save_local_path))
    # ########################################
    # # upload batch data to s3
    # ########################################
    # print("finish batch and upload to s3 position!")
    # print("upload pickle file")
    # s3_batch_pickle_folder = "recommender-system-news-open-toutiao/feature/content/inverted-list/"
    # for f in pickle_batch_file_list:
    #     print("upload batch pickle file {}: upload src key {} to dst key {}".format(f, os.path.join(
    #         save_folder, f), os.path.join(s3_batch_pickle_folder, f)))
    #     s3client.upload_file( os.path.join(
    #         save_folder, f), bucket, os.path.join(s3_batch_pickle_folder, f))
    # print("upload encoding file")
    # s3_batch_encoding_folder = "recommender-system-news-open-toutiao/feature/content/encode/"
    # for f in encoding_batch_file_list:
    #     print("upload batch encode file {}: upload src key {} to dst key {}".format(f, os.path.join(
    #         save_folder, f), os.path.join(s3_batch_encoding_folder, f)))
    #     s3client.upload_file( os.path.join(
    #         save_folder, f), bucket, os.path.join(s3_batch_encoding_folder, f))
    # print("upload index file")
    # s3_batch_index_folder = "recommender-system-news-open-toutiao/model/recall/vector/"
    # for f in encoding_batch_file_list:
    #     print("upload batch encode file {}: upload src key {} to dst key {}".format(f, os.path.join(
    #         save_folder, f), os.path.join(s3_batch_index_folder, f)))
    #     s3client.upload_file( os.path.join(
    #         save_folder, f), bucket, os.path.join(s3_batch_index_folder, f))

    print("pickle_batch_file_list", pickle_batch_file_list)
    print("encoding_batch_file_list", encoding_batch_file_list)
    print("index_batch_file_list", index_batch_file_list)

# The main routine just invokes the start function.
if __name__ == '__main__':
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

    batch_process(bucket, key_prefix)
