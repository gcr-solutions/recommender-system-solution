#!/usr/bin/env bash

echo "run $0 ..."
pwd

#export PROFILE=rsops
#export REGION=ap-southeast-1

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

cf_stacks=(
steps
item-new
action-new
knowledge-mapping
overall
)

for stack in ${cf_stacks[@]};
do
   STACK_NAME=rsdemo-${stack}-stepsfuncs
   template_file=${stack}-template.yaml

   echo "STACK_NAME: ${STACK_NAME}"
   echo "template_file: $template_file"

   aws --profile $PROFILE cloudformation deploy --region ${REGION} \
   --template-file ${template_file} --stack-name ${STACK_NAME} \
   --parameter-overrides ${PARAMETER_OVERRIDES} \
   --capabilities CAPABILITY_NAMED_IAM

   if [[ $? -ne 0 ]]; then
     echo "error!!!"
     exit 1
   fi
done


