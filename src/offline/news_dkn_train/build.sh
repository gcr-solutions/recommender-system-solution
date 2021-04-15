#!/usr/bin/env bash

if [[ -z $PROFILE ]];then
   PROFILE='default'
fi

if [[ -z $REGION ]];then
    REGION='us-east-1'
fi


echo "PROFILE: $PROFILE"
echo "REGION: $REGION"

AWS_REGION=$REGION
AWS_PROFILE=$PROFILE

# repo 相关信息
repo_name=news-dkn-train
#tag=`date '+%Y%m%d%H%M%S'`
tag="latest"

aws ecr create-repository --profile $AWS_PROFILE \
  --repository-name $repo_name \
  --image-scanning-configuration scanOnPush=true \
  --region $AWS_REGION >/dev/null 2>&1


# account_id和region是对应最后要push的ECR
account_id=`aws --profile ${AWS_PROFILE} sts get-caller-identity --query Account --output text`


aws --profile ${AWS_PROFILE} ecr create-repository \
  --repository-name $repo_name \
  --image-scanning-configuration scanOnPush=true \
  --region $AWS_REGION >/dev/null 2>&1


# 基础镜像相关的account_id以及ecr的地址
if [[ $AWS_REGION =~ ^cn.* ]]
then
    registry_id="727897471807"
    registry_uri="${registry_id}.dkr.ecr.${AWS_REGION}.amazonaws.com.cn"
    account_uri="${account_id}.dkr.ecr.${AWS_REGION}.amazonaws.com.cn"
else
    registry_id="763104351884"
    registry_uri="${registry_id}.dkr.ecr.${AWS_REGION}.amazonaws.com"
    account_uri="${account_id}.dkr.ecr.${AWS_REGION}.amazonaws.com"
fi


echo "registry_uri (base): $registry_uri"
echo "account_uri: $account_uri"


# login 到基础镜像的ecr
aws --profile ${AWS_PROFILE} ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${registry_uri}

# build image
docker build -t $repo_name . --build-arg REGISTRY_URI=${registry_uri}

# 打tag
docker tag $repo_name $account_uri/$repo_name:${tag}

# login 到自己的ecr
aws --profile ${AWS_PROFILE} ecr get-login-password --region ${AWS_REGION} | docker login --username AWS  --password-stdin ${account_uri}
# 判断自己的账户下有没有相应的repo
#aws --profile ${AWS_PROFILE} ecr describe-repositories --repository-names $repo_name || aws --profile ${AWS_PROFILE} ecr create-repository --repository-name $repo_name

# push repo
docker push $account_uri/$repo_name:${tag}



