
AWS_PROFILE='--profile aoyu'
AWS_REGION='us-east-1'

TIMESTAMP=$(date '+%Y%m%dT%H%M%S')
repoName=news-gen-item-map

JOB_NAME=${repoName}-${TIMESTAMP}-${RANDOM}

IMAGEURI=002224604296.dkr.ecr.us-east-1.amazonaws.com/${repoName}:latest
role=arn:aws:iam::002224604296:role/service-role/RSSagemakerRole 

echo "JOB_NAME: ${JOB_NAME}"

bucket=sagemaker-us-east-1-002224604296
input_prefix=recommender-system-news-open-toutiao/system/item-data/raw-input/
output_prefix=recommender-system-news-open-toutiao/system/item-data/emr-out/

aws sagemaker ${AWS_PROFILE} --region  ${AWS_REGION}   create-processing-job \
--processing-job-name ${JOB_NAME} \
--role-arn ${role} \
--processing-resources 'ClusterConfig={InstanceCount=1,InstanceType=ml.m5.xlarge,VolumeSizeInGB=5}' \
--app-specification "ImageUri=${IMAGEURI},ContainerArguments=--s3_bucket,${bucket},--s3_input_key_prefix,${input_prefix},--s3_output_key_prefix ${output_prefix}"

