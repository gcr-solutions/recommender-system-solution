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


echo "REGION: $REGION"

AWS_ACCOUNT_ID=$(aws  sts get-caller-identity  --o text | awk '{print $1}')
echo "AWS_ACCOUNT_ID: ${AWS_ACCOUNT_ID}"

BUCKET=aws-gcr-rs-sol-workshop-${REGION}-${AWS_ACCOUNT_ID}
S3Prefix=sample-data

PARAMETER_OVERRIDES="Bucket=$BUCKET S3Prefix=$S3Prefix"

 STACK_NAME=rsdemo-role
 echo "STACK_NAME: ${STACK_NAME}"
 aws  cloudformation deploy --region ${REGION} \
 --template-file ./template_role.yaml --stack-name ${STACK_NAME} \
 --capabilities CAPABILITY_NAMED_IAM

 StackStatus=$(aws  cloudformation  describe-stacks --region ${REGION} --stack-name ${STACK_NAME} --output table | grep StackStatus)
 echo ${StackStatus}
 echo ${StackStatus} |  grep CREATE_COMPLETE > /dev/null

 if [[ $? -ne 0 ]]; then
   echo "error!!!"
   exit 1
fi


STACK_NAME=rsdemo-lambda-stack
echo "STACK_NAME: ${STACK_NAME}"
aws  cloudformation deploy --region ${REGION} \
--template-file ./template.yaml --stack-name ${STACK_NAME} \
--parameter-overrides ${PARAMETER_OVERRIDES} \
--capabilities CAPABILITY_NAMED_IAM

 StackStatus=$(aws  cloudformation  describe-stacks --region ${REGION} --stack-name ${STACK_NAME} --output table | grep StackStatus)
 echo ${StackStatus} |  grep CREATE_COMPLETE > /dev/null

 if [[ $? -ne 0 ]]; then
      Error_print "error!!!  ${StackStatus}"
      exit 1
 fi

OK_print "${StackStatus}"

exit 0
