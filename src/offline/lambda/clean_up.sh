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


all_stepfuncs=(
rsdemo-role
rsdemo-lambda-stack
)

for name in ${all_stepfuncs[@]};
do
    STACK_NAME=$name
    echo "----"
    echo "Clean STACK_NAME: ${STACK_NAME}"
    aws  cloudformation delete-stack --region ${REGION} --stack-name ${STACK_NAME}
done

aws  s3 rm s3://${BUCKET}/${S3Prefix}/code/lambda/  --recursive

