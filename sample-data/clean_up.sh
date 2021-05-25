#!/usr/bin/env bash

echo "################"
echo "run $0 ..."
pwd

if [[ -z $REGION ]];then
    REGION='ap-northeast-1'
fi

echo "REGION: $REGION"

AWS_ACCOUNT_ID=$(aws  sts get-caller-identity  --o text | awk '{print $1}')
echo "AWS_ACCOUNT_ID: ${AWS_ACCOUNT_ID}"

BUCKET=aws-gcr-rs-sol-workshop-${REGION}-${AWS_ACCOUNT_ID}
S3Prefix=sample-data

#aws  s3 rm s3://${BUCKET}/${S3Prefix}  --recursive
aws s3 rm s3://${BUCKET}/ --recursive
aws s3api delete-bucket --bucket ${BUCKET}

