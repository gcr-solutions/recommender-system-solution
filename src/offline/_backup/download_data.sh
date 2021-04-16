#!/usr/bin/env bash

echo "run $0 ..."
pwd

PROFILE=aoyu

if [[ -z $PROFILE ]];then
   PROFILE='default'
fi

echo PROFILE: $PROFILE

data_files=(
model/sort/content/words/sgns-mixed-large/dkn_word_embedding.npy
model/news_map.csv/news_map.csv
model/user_map.csv/user_map.csv
model/sort/content/words/mapping/kg_dbpedia.txt
model/sort/content/words/mapping/entities_dbpedia.dict
model/sort/content/words/mapping/relations_dbpedia.dict
model/sort/content/words/mapping/entity_industry.txt
model/sort/content/words/mapping/vocab.json
system/item-data/raw-input/toutiao_cat_data.txt
)

sync_data=(
system/user-data/raw_action_data/
)

code_files=(
code/lambda/precheck-lambda.zip
code/lambda/s3-util-lambda.zip
code/lambda/query-training-result-lambda.zip
code/lambda/sns-message-lambda.zip
)

src_prefix=s3://sagemaker-us-east-1-002224604296/recommender-system-news-open-toutiao
src_prefix_code=s3://sagemaker-us-east-1-002224604296

dist_prefix=s3://sagemaker-ap-southeast-1-522244679887/rsdemo

mkdir data_files code_files raw_action_data

for file in ${data_files[@]};
do
  echo "s3 sync $src_prefix/$file data_files/"
  aws --profile $PROFILE s3 sync $src_prefix/$file  data_files/
done

for file in ${code_files[@]};
do
  echo "s3 sync $src_prefix_code/$file  code_files/"
  aws --profile $PROFILE s3 sync $src_prefix_code/$file  code_files/
done


for file in ${sync_data[@]};
do
  echo "s3 sync $src_prefix/$file  raw_action_data/"
  aws --profile $PROFILE s3 sync $src_prefix/$file  raw_action_data/
done








