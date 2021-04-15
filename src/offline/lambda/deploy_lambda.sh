#!/usr/bin/env bash

#export PROFILE=rsops
#export REGION=ap-southeast-1

echo "run $0 ..."
pwd

if [[ -z $PROFILE ]];then
   PROFILE='default'
fi

if [[ -z $REGION ]];then
    REGION='us-east-1'
fi

echo "PROFILE: $PROFILE"
echo "REGION: $REGION"


AWS_ACCOUNT_ID=$(aws --profile $PROFILE sts get-caller-identity  --o text | awk '{print $1}')
echo "AWS_ACCOUNT_ID: ${AWS_ACCOUNT_ID}"

BUCKET=sagemaker-${REGION}-${AWS_ACCOUNT_ID}

PARAMETER_OVERRIDES="Bucket=$BUCKET"
STACK_NAME=rsdemo-lambda-stack

echo "STACK_NAME: ${STACK_NAME}"

aws --profile $PROFILE cloudformation deploy --region ${REGION} \
--template-file ./template.yaml --stack-name ${STACK_NAME} \
--parameter-overrides ${PARAMETER_OVERRIDES} \
--capabilities CAPABILITY_NAMED_IAM

if [[ $? -ne 0 ]]; then
  echo "error!!!"
  exit 1
fi

