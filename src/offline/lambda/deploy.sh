#!/usr/bin/env bash

echo "run $0 ..."
pwd

rm -rf deploy >/dev/null 2>&1

if [[ -z $REGION ]];then
  REGION=$(aws configure get region)
fi

echo "REGION=$REGION"

if [[ -z $REGION ]]; then
  echo "REGION not set"
  exit 1
fi

mkdir deploy/
cd deploy/

cp ../*.* .

pip install --target ./package requests

AWS_ACCOUNT_ID=$(aws sts get-caller-identity  --o text | awk '{print $1}')
echo AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID}

BUCKET_BUILD=rs-build-${REGION}-${AWS_ACCOUNT_ID}
echo "BUCKET_BUILD=${BUCKET_BUILD}"
echo "Create S3 Bucket: ${BUCKET_BUILD} if not exist"
aws s3 mb s3://${BUCKET_BUILD}  >/dev/null 2>&1


SNS=rs-offline-sns
echo "Create SNS: $SNS if not exist"
aws sns create-topic --name ${SNS} --region ${REGION}


echo ""
sed -e "s/__REGION__/${REGION}/g" config.json > p.json
sed -e "s/__AWS_ACCOUNT_ID__/${AWS_ACCOUNT_ID}/g" p.json > config.json
cat config.json
echo ""

PARAMETER_OVERRIDES=$(./read_params.py)
echo "PARAMETER_OVERRIDES:${PARAMETER_OVERRIDES}"

#
# Create lambda
#
lambda_funcs=(
  precheck-lambda
  s3-util-lambda
  query-training-result-lambda
  sns-message-lambda
)

for lambda_func in ${lambda_funcs[@]}; do
  cd package
  zip -r ../${lambda_func}.zip .
  cd ..
  zip -g ${lambda_func}.zip ./${lambda_func}.py

  if [[ $? -ne 0 ]]; then
    echo "error!!!"
    exit 1
  fi
  rm ./${lambda_func}.py
done

INPUT_FiLE=template.yaml
OUTPUT_FILE=packaged-${INPUT_FiLE}

STACK_NAME=rs-lambda-stack

echo "Start creating stack ${STACK_NAME} using ${INPUT_FiLE} ..."
aws cloudformation package  --region ${REGION} \
--template-file ${INPUT_FiLE} \
--s3-bucket ${BUCKET_BUILD} \
--output-template-file ${OUTPUT_FILE}

if [[ $? -ne 0 ]]; then
  echo "error!!!"
  exit 1
fi

aws cloudformation deploy  --region ${REGION} \
--template-file ${OUTPUT_FILE} --stack-name ${STACK_NAME} \
--parameter-overrides ${PARAMETER_OVERRIDES} \
--capabilities CAPABILITY_NAMED_IAM

if [[ $? -ne 0 ]]; then
  echo "error!!!"
  exit 1
fi

cd ..
rm -rf deploy
