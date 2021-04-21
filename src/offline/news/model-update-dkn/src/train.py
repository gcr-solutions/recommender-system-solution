from __future__ import print_function

import glob
import os
import sys
import math
import pickle
import boto3
import os
import numpy as np
import pandas as pd
# from tqdm import tqdm
import time
import argparse
import logging
import re
import shutil
import subprocess
import json
# tqdm.pandas()
# pandarallel.initialize(progress_bar=True)
# bucket = os.environ.get("BUCKET_NAME", " ")
# raw_data_folder = os.environ.get("RAW_DATA", " ")
# logger = logging.getLogger()
# logger.setLevel(logging.INFO)
# tqdm_notebook().pandas()


s3client = boto3.client('s3')

########################################
# 从s3同步数据
########################################


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

def run_script(script):
    print("run_script: '{}'".format(script))
    re_code, out_msg = subprocess.getstatusoutput([script])
    print("run_script re_code:", re_code)
    for line in out_msg.split("\n"):
        print(line)
    if re_code != 0:
        raise Exception(out_msg)

param_path = os.path.join('/opt/ml/', 'input/config/hyperparameters.json')
parser = argparse.ArgumentParser()
model_dir = ''
default_bucket = 'aws-gcr-rs-sol-workshop-ap-southeast-1-522244679887'
default_prefix = 'sample-data'

if os.path.exists(param_path):
    # running training job

    # print("load param from {}".format(param_path))
    # with open(param_path) as f:
    #     hp = json.load(f)
    #     bucket = hp['bucket']
    #     prefix = hp['prefix']

    parser.add_argument('--bucket', type=str)
    parser.add_argument('--prefix', type=str)
    parser.add_argument('--model_dir', type=str,
                        default=os.environ.get('SM_MODEL_DIR', ''))
    parser.add_argument('--training_dir', type=str,
                        default=os.environ.get('SM_CHANNEL_TRAINING', ''))
    parser.add_argument('--validation_dir', type=str,
                        default=os.environ.get('SM_CHANNEL_VALIDATION', ''))
    args, _ = parser.parse_known_args()
    bucket = args.bucket
    prefix = args.prefix
    model_dir = args.model_dir
    training_dir = args.training_dir
    validation_dir = args.validation_dir
    print("model_dir: {}".format(model_dir))
    print("training_dir: {}".format(training_dir))
    print("validation_dir: {}".format(validation_dir))

else:
    # running processing job
    parser.add_argument('--bucket', type=str, default=default_bucket)
    parser.add_argument('--prefix', type=str, default=default_prefix)
    args, _ = parser.parse_known_args()
    bucket = args.bucket
    prefix = args.prefix

if prefix.endswith("/"):
    prefix = prefix[:-1]

print("bucket={}".format(bucket))
print("prefix='{}'".format(prefix))

model_s3_key = "{}/model/rank/action/dkn/latest/model.tar.gz".format(prefix)
os.chdir("/opt/ml/code/")

local_folder = 'info'
if not os.path.exists(local_folder):
    os.makedirs(local_folder)
# dkn模型文件下载
file_name_list = ['dkn_entity_embedding.npy','dkn_context_embedding.npy','dkn_word_embedding.npy']
s3_folder = '{}/model/rank/content/dkn_embedding_latest/'.format(prefix)
sync_s3(file_name_list, s3_folder, local_folder)

local_folder = 'model-update-dkn/train'
if not os.path.exists(local_folder):
    os.makedirs(local_folder)
file_name_list = ['action_train.csv']
# s3://aws-gcr-rs-sol-workshop-ap-southeast-1-522244679887/sample-data/system/action-data/action_train.csv
s3_folder = '{}/system/action-data/'.format(prefix)
sync_s3(file_name_list, s3_folder, local_folder)

local_folder = 'model-update-dkn/val'
if not os.path.exists(local_folder):
    os.makedirs(local_folder)
file_name_list = ['action_val.csv']
s3_folder = '{}/system/action-data/'.format(prefix)
sync_s3(file_name_list, s3_folder, local_folder)

shutil.copy("info/dkn_entity_embedding.npy", "model-update-dkn/train/entity_embeddings_TransE_128.npy")
shutil.copy("info/dkn_context_embedding.npy", "model-update-dkn/train/context_embeddings_TransE_128.npy")
shutil.copy("info/dkn_word_embedding.npy", "model-update-dkn/train/word_embeddings_300.npy")

run_script("./embed_dkn_wrapper.sh")
model_file = "./model-update-dkn/model_latest/model.tar.gz"

if not os.path.exists(model_file):
    raise Exception("Cannot find file model.tar.gz")

write_to_s3(model_file, bucket, model_s3_key)

if model_dir:
    print("copy file {} to {}".format(model_file, model_dir))
    shutil.copyfile(model_file, os.path.join(model_dir, "model.tar.gz"))

#
# !python embed_dkn.py --learning_rate 0.0001 --loss_weight 1.0 --max_click_history 16 --num_epochs 1 --use_entity True --use_context 0 --max_title_length 16 --entity_dim 128 --word_dim 300 --batch_size 128 --perform_shuffle 1 --data_dir /home/ec2-user/workplace/recommender-system-solution/src/offline/news/model-update-dkn --checkpointPath /home/ec2-user/workplace/recommender-system-solution/src/offline/news/model-update-dkn/temp/ --servable_model_dir /home/ec2-user/workplace/recommender-system-solution/src/offline/news/model-update-dkn/model_complete/

# !aws s3 cp s3://gcr-rs-ops-ap-southeast-1-522244679887/news-open/model/rank/content/dkn_embedding_latest/dkn_context_embedding.npy s3://aws-gcr-rs-sol-workshop-ap-southeast-1-522244679887/sample-data/model/rank/content/dkn_embedding_latest/dkn_context_embedding.npy --acl bucket-owner-full-control
# !aws s3 cp s3://gcr-rs-ops-ap-southeast-1-522244679887/news-open/model/rank/content/dkn_embedding_latest/dkn_entity_embedding.npy s3://aws-gcr-rs-sol-workshop-ap-southeast-1-522244679887/sample-data/model/rank/content/dkn_embedding_latest/dkn_entity_embedding.npy --acl bucket-owner-full-control
# !aws s3 cp s3://gcr-rs-ops-ap-southeast-1-522244679887/news-open/model/rank/content/dkn_embedding_latest/dkn_word_embedding.npy s3://aws-gcr-rs-sol-workshop-ap-southeast-1-522244679887/sample-data/model/rank/content/dkn_embedding_latest/dkn_word_embedding.npy --acl bucket-owner-full-control
# !aws s3 cp s3://gcr-rs-ops-ap-southeast-1-522244679887/news-open/model/rank/action/dkn/latest/model.tar.gz s3://aws-gcr-rs-sol-workshop-ap-southeast-1-522244679887/sample-data/model/rank/action/dkn/latest/model.tar.gz --acl bucket-owner-full-control

