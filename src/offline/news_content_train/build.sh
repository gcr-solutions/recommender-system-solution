#!/usr/bin/env bash

AWS_PROFILE=aoyu

# account_id和region是对应最后要push的ECR
account_id=`aws --profile ${AWS_PROFILE} sts get-caller-identity --query Account --output text`

#s = boto3.session.Session()
#s.region_name

region=us-east-1  # aws configure --profile $AWS_PROFILE get region
# repo 相关信息
repo_name=news-content-train
#tag=`date '+%Y%m%d%H%M%S'`
tag="latest"


aws --profile ${AWS_PROFILE} ecr create-repository \
  --repository-name $repo_name \
  --image-scanning-configuration scanOnPush=true \
  --region $region >/dev/null 2>&1


# 基础镜像相关的account_id以及ecr的地址
if [[ $region =~ ^cn.* ]]
then
    registry_id="727897471807"
    registry_uri="${registry_id}.dkr.ecr.${region}.amazonaws.com.cn"
    account_uri="${account_id}.dkr.ecr.${region}.amazonaws.com.cn"
else
    registry_id="763104351884"
    registry_uri="${registry_id}.dkr.ecr.${region}.amazonaws.com"
    account_uri="${account_id}.dkr.ecr.${region}.amazonaws.com"
fi


echo "registry_uri (base): $registry_uri"
echo "account_uri: $account_uri"


# login 到基础镜像的ecr
aws --profile ${AWS_PROFILE} ecr get-login-password --region ${region} | docker login --username AWS --password-stdin ${registry_uri}

# build image
docker build -t $repo_name . --build-arg REGISTRY_URI=${registry_uri}

# 打tag
docker tag $repo_name $account_uri/$repo_name:${tag}

# login 到自己的ecr
aws --profile ${AWS_PROFILE} ecr get-login-password --region ${region} | docker login --username AWS  --password-stdin ${account_uri}
# 判断自己的账户下有没有相应的repo
#aws --profile ${AWS_PROFILE} ecr describe-repositories --repository-names $repo_name || aws --profile ${AWS_PROFILE} ecr create-repository --repository-name $repo_name

# push repo
docker push $account_uri/$repo_name:${tag}
