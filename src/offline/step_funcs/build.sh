#!/usr/bin/env bash

echo "run $0 ..."
pwd

if [[ -z $REGION ]];then
    REGION='ap-northeast-1'
fi

echo REGION=$REGION
AWS_REGION=$REGION


AWS_ACCOUNT_ID=$(aws  sts get-caller-identity  --o text | awk '{print $1}')
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

    aws  cloudformation deploy --region ${REGION} \
    --template-file ${template_file} --stack-name ${STACK_NAME} \
    --parameter-overrides ${PARAMETER_OVERRIDES} \
    --capabilities CAPABILITY_NAMED_IAM

    aws  cloudformation  describe-stacks --region ${REGION} --stack-name ${STACK_NAME} --ouput table
    if [[ $? -ne 0 ]]; then
      echo "error!!!"
      exit 1
   fi
done

