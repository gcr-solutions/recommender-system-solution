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

repoName=news-item-preprocessing
tag="latest"

account_id=$(aws --profile ${AWS_PROFILE} sts get-caller-identity --query Account --output text)
account_ecr_uri=${account_id}.dkr.ecr.${AWS_REGION}.amazonaws.com

IMAGEURI=${account_ecr_uri}/$repoName:${tag}

echo "IMAGEURI: $IMAGEURI"

aws ecr create-repository --profile $AWS_PROFILE \
  --repository-name $repoName \
  --image-scanning-configuration scanOnPush=true \
  --region $AWS_REGION >/dev/null 2>&1

if [[ $AWS_REGION == 'us-east-1' ]]; then
  registry_uri=173754725891.dkr.ecr.${AWS_REGION}.amazonaws.com
elif [[ $AWS_REGION == 'ap-southeast-1' ]]; then
  registry_uri=759080221371.dkr.ecr.${AWS_REGION}.amazonaws.com
elif [[ $AWS_REGION == 'us-east-2' ]]; then
  registry_uri=314815235551.dkr.ecr.${AWS_REGION}.amazonaws.com
elif [[ $AWS_REGION == 'ap-northeast-1' ]]; then
  registry_uri=411782140378.dkr.ecr.${AWS_REGION}.amazonaws.com
elif [[ $AWS_REGION == 'ap-northeast-2' ]]; then
  registry_uri=860869212795.dkr.ecr.${AWS_REGION}.amazonaws.com
elif [[ $AWS_REGION == 'ap-east-1' ]]; then
  registry_uri=732049463269.dkr.ecr.${AWS_REGION}.amazonaws.com
elif [[ $AWS_REGION == 'cn-north-1' ]]; then
  registry_uri=671472414489.dkr.ecr.${AWS_REGION}.amazonaws.com
fi

echo registry_uri=$registry_uri

aws ecr get-login-password --profile ${AWS_PROFILE} --region ${AWS_REGION} | docker login --username AWS --password-stdin ${registry_uri}

docker build -t $repoName . --build-arg REGISTRY_URI=${registry_uri}

docker tag $repoName:${tag} ${IMAGEURI}

echo ${IMAGEURI}

aws ecr get-login-password --profile ${AWS_PROFILE} --region ${AWS_REGION} | docker login --username AWS --password-stdin ${account_ecr_uri}

docker push ${IMAGEURI}
