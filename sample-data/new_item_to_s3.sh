#!/usr/bin/env bash

echo "################"
echo "run $0 ..."
pwd

if [[ -z $PROFILE ]];then
   PROFILE='default'
fi

if [[ -z $REGION ]];then
    REGION='ap-southeast-1'
fi

echo "PROFILE: $PROFILE"
echo "REGION: $REGION"

AWS_ACCOUNT_ID=$(aws --profile ${PROFILE}  sts get-caller-identity  --o text | awk '{print $1}')
echo "AWS_ACCOUNT_ID: ${AWS_ACCOUNT_ID}"

BUCKET=aws-gcr-rs-sol-demo-${REGION}-${AWS_ACCOUNT_ID}
PREFIX=sample-data

echo "BUCKET=${BUCKET}"

aws --profile ${PROFILE}  s3 cp new_news.csv s3://${BUCKET}/${PREFIX}/system/ingest-data/item/

if [[ $? -ne 0 ]]; then
      echo "error!!! aws s3 cp item_new.csv s3://${BUCKET}/${PREFIX}/system/ingest-data/item/"
      exit 1
fi



