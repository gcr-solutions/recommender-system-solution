
export PROFILE='rsops'
export REGION='ap-southeast-1'

if [[ -z $PROFILE ]]; then
  PROFILE='default'
fi

if [[ -z $REGION ]]; then
  REGION='ap-southeast-1'
fi

echo "PROFILE: $PROFILE"
echo "REGION: $REGION"

AWS_REGION=$REGION
AWS_PROFILE=$PROFILE

TIMESTAMP=$(date '+%Y%m%dT%H%M%S')
account_id=$(aws --profile ${AWS_PROFILE} sts get-caller-identity --query Account --output text)

repo_name=news-dashboard

JOB_NAME=${repo_name}-${TIMESTAMP}-${RANDOM}

IMAGEURI=${account_id}.dkr.ecr.${AWS_REGION}.amazonaws.com/${repo_name}:latest
SM_ROLE=arn:aws:iam::${account_id}:role/service-role/RSSMRole

echo "JOB_NAME: ${JOB_NAME}"

bucket=aws-gcr-rs-sol-workshop-${AWS_REGION}-${account_id}
prefix=sample-data

aws sagemaker --profile ${AWS_PROFILE} --region  ${AWS_REGION}   create-processing-job \
--processing-job-name ${JOB_NAME} \
--role-arn ${SM_ROLE} \
--processing-resources 'ClusterConfig={InstanceCount=1,InstanceType=ml.m5.xlarge,VolumeSizeInGB=5}' \
--app-specification "ImageUri=${IMAGEURI},ContainerArguments=--bucket,${bucket},--prefix,${prefix}"

