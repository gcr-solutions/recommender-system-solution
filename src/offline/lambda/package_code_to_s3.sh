#!/usr/bin/env bash

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

BUCKET_BUILD=sagemaker-${REGION}-${AWS_ACCOUNT_ID}
# sagemaker-us-east-1-002224604296

echo "BUCKET_BUILD=${BUCKET_BUILD}"
echo "Create S3 Bucket: ${BUCKET_BUILD} if not exist"
aws --profile $PROFILE s3 mb s3://${BUCKET_BUILD}  >/dev/null 2>&1


lambda_funcs=(
  precheck-lambda
  s3-util-lambda
  query-training-result-lambda
  sns-message-lambda
)

rm -rf deploy >/dev/null 2>&1

mkdir deploy/
cd deploy/

pip install --target ./package requests >/dev/null

for lambda_func in ${lambda_funcs[@]}; do
  cp ../${lambda_func}.py .
  cd package
  zip -r ../${lambda_func}.zip . >/dev/null
  cd ..
  zip -g ${lambda_func}.zip ./${lambda_func}.py

  if [[ $? -ne 0 ]]; then
    echo "error!!!"
    exit 1
  fi
  rm ./${lambda_func}.py
done

rm -rf package

aws --profile $PROFILE s3 sync . s3://${BUCKET_BUILD}/rsdemo/code/lambda/
