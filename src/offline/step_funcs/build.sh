#!/usr/bin/env bash

echo "################"
Red=$'\e[1;31m'
Green=$'\e[1;32m'

OK_print () {
   echo "$Green $1 \e[0m"
}
Error_print() {
	 echo "$Red $1 \e[0m"
}

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

     StackStatus=$(aws  cloudformation  describe-stacks --region ${REGION} --stack-name ${STACK_NAME} --output table | grep StackStatus)
     echo ${StackStatus} |  grep CREATE_COMPLETE > /dev/null

     if [[ $? -ne 0 ]]; then
         Error_print "error!!!  ${StackStatus}"
         exit 1
     fi
     OK_print "${StackStatus}"
done

StepInput="{
  \"Bucket\": \"${BUCKET}\",
  \"S3Prefix\": \"$S3Prefix\",
  \"change_type\": \"CONTENT|ACTION|MODEL\"
}"
echo ""
OK_print "stepfuncs deploy completed. You can run stepfuncs with below input"
echo ${StepInput}
echo ""