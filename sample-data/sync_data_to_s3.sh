#!/usr/bin/env bash

echo "################"
Red=$'\e[1;31m'
Green=$'\e[1;32m'
Yellow=$'\e[1;33m'
Blue=$'\e[1;34m'

OK_print () {
   echo -e "$Green $1 \e[39m"
}
Error_print() {
	 echo -e "$'\e[1;31m' $1 \e[39m"
}

Yellow_print() {
  echo -e "$Yellow $1 \e[39m"
}

Blue_print() {
  echo -e "$Blue $1 \e[39m"
}

echo "run $0 ..."
pwd

if [[ -z $REGION ]];then
    REGION='ap-northeast-1'
fi

Yellow_print "REGION: $REGION"

AWS_ACCOUNT_ID=$(aws  sts get-caller-identity  --o text | awk '{print $1}')
Yellow_print "AWS_ACCOUNT_ID: ${AWS_ACCOUNT_ID}"

BUCKET_BUILD=aws-gcr-rs-sol-workshop-${REGION}-${AWS_ACCOUNT_ID}
PREFIX=sample-data

echo "BUCKET_BUILD=${BUCKET_BUILD}"
echo "Create S3 Bucket: ${BUCKET_BUILD} if not exist"
aws  s3 mb s3://${BUCKET_BUILD}  >/dev/null 2>&1

echo "########################################################"
Blue_print "aws  s3 sync . s3://${BUCKET_BUILD}/${PREFIX}/"
echo "########################################################"

aws  s3 sync . s3://${BUCKET_BUILD}/${PREFIX}/
if [[ $? -ne 0 ]]; then
      Error_print "error!!! aws  s3 sync . s3://${BUCKET_BUILD}/${PREFIX}/"
      exit 1
fi

echo "Copy complete_dkn_word_embedding.npy ..."

s3_file_complete_dkn_word_embedding=s3://aws-gcr-rs-sol-workshop-ap-northeast-1-common/dkn_embedding_latest/complete_dkn_word_embedding.npy
aws s3 cp ${s3_file_complete_dkn_word_embedding} \
s3://${BUCKET_BUILD}/${PREFIX}/model/rank/content/dkn_embedding_latest/complete_dkn_word_embedding.npy  --acl bucket-owner-full-control

if [[ $? -ne 0 ]]; then
      Error_print "error!!! Copy $s3_file_complete_dkn_word_embedding"
      exit 1
fi

OK_print "data sync completed"
