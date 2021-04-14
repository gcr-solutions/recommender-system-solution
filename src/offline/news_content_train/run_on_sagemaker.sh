
AWS_PROFILE='--profile aoyu'
AWS_REGION='us-east-1'

TIMESTAMP=$(date '+%Y%m%dT%H%M%S')
repoName=news-content-train

JOB_NAME=${repoName}-${TIMESTAMP}-${RANDOM}

IMAGEURI=002224604296.dkr.ecr.us-east-1.amazonaws.com/${repoName}:latest
role=arn:aws:iam::002224604296:role/service-role/RSSagemakerRole 

echo "JOB_NAME: ${JOB_NAME}"

bucket=sagemaker-us-east-1-002224604296
s3_key_prefix=recommender-system-news-open-toutiao

sed -e "s#__TrainingJobName__#${JOB_NAME}#g" train_template.json >  tmp_train_1.json
sed -e "s#__TrainingImage__#${IMAGEURI}#g" tmp_train_1.json >  tmp_train_2.json
sed -e "s#__BUCKET__#${bucket}#g" tmp_train_2.json >  tmp_train_3.json
sed -e "s#__KEY_PREFIX__#${s3_key_prefix}#g" tmp_train_3.json >  tmp_train_4.json
sed -e "s#__RoleArn__#${role}#g" tmp_train_4.json >  train.json

rm tmp_train*.json

aws sagemaker ${AWS_PROFILE} --region  ${AWS_REGION}   create-training-job  --cli-input-json file://./train.json

