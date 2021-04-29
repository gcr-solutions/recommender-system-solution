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
    echo "----"
    echo "Clean STACK_NAME: ${STACK_NAME}"
    aws  cloudformation delete-stack --region ${REGION} --stack-name ${STACK_NAME}
done

