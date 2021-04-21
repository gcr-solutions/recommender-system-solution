#!/usr/bin/env bash

export PROFILE=rsops
export REGION=ap-southeast-1

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

BUCKET=aws-gcr-rs-sol-workshop-${REGION}-${AWS_ACCOUNT_ID}
S3Prefix=sample-data

PARAMETER_OVERRIDES="Bucket=$BUCKET S3Prefix=$S3Prefix"
echo PARAMETER_OVERRIDES:$PARAMETER_OVERRIDES

all_stepfuncs=(
steps
dashboard
action-new
item-new
train-model
overall
)

for name in ${all_stepfuncs[@]};
do

    STACK_NAME=rsdemo-news-${name}-stack
    template_file=${name}-template.yaml
    echo "----"
    echo "STACK_NAME: ${STACK_NAME}"
    echo "template_file: ${template_file}"

    aws --profile $PROFILE cloudformation deploy --region ${REGION} \
    --template-file ${template_file} --stack-name ${STACK_NAME} \
    --parameter-overrides ${PARAMETER_OVERRIDES} \
    --capabilities CAPABILITY_NAMED_IAM

    if [[ $? -ne 0 ]]; then
      echo "error!!!"
      exit 1
    fi

done

