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
S3Prefix=sample-data

aws --profile ${PROFILE}  s3 rm s3://${BUCKET}/${S3Prefix}  --recursive


