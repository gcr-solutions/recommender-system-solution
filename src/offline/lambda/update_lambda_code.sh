
if [[ -z $REGION ]];then
    REGION='ap-northeast-1'
fi

echo "REGION: $REGION"
AWS_ACCOUNT_ID=$(aws  sts get-caller-identity  --o text | awk '{print $1}')
echo "AWS_ACCOUNT_ID: ${AWS_ACCOUNT_ID}"

BUCKET_BUILD=aws-gcr-rs-sol-workshop-${REGION}-${AWS_ACCOUNT_ID}
PREFIX=sample-data


lambda_funcs_name=(
 rsdemo-PreCheckLabmda
 rsdemo-S3UtilLabmda
 rsdemo-SNSMessageLambda
)

lambda_funcs_code=(
 precheck-lambda.zip
 s3-util-lambda.zip
 sns-message-lambda.zip
)

i=0

for lambda_func_name in ${lambda_funcs_name[@]}; do
  echo "---"
  echo $lambda_func_name
  code_file=${PREFIX}/code/lambda/${lambda_funcs_code[$i]}
  echo $code_file
  aws  lambda  update-function-code --function-name ${lambda_func_name} \
  --s3-bucket ${BUCKET_BUILD} \
  --s3-key $code_file >/dev/null
  i=$(( $i+1 ))
done
