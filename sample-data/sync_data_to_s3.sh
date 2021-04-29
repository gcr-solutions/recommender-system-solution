#!/usr/bin/env bash
echo "run $0 ..."
pwd

if [[ -z $REGION ]];then
    REGION='ap-northeast-1'
fi

echo "REGION: $REGION"

AWS_ACCOUNT_ID=$(aws  sts get-caller-identity  --o text | awk '{print $1}')
echo "AWS_ACCOUNT_ID: ${AWS_ACCOUNT_ID}"

BUCKET_BUILD=aws-gcr-rs-sol-workshop-${REGION}-${AWS_ACCOUNT_ID}
PREFIX=sample-data

echo "BUCKET_BUILD=${BUCKET_BUILD}"
echo "Create S3 Bucket: ${BUCKET_BUILD} if not exist"
aws  s3 mb s3://${BUCKET_BUILD}  >/dev/null 2>&1
echo "s3 sync lambda_code/ s3://${BUCKET_BUILD}/${PREFIX}/code/lambda/"
aws  s3 sync . s3://${BUCKET_BUILD}/${PREFIX}/
if [[ $? -ne 0 ]]; then
      echo "error!!! aws  s3 sync . s3://${BUCKET_BUILD}/${PREFIX}/"
      exit 1
fi

