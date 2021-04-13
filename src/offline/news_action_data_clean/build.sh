AWS_PROFILE='--profile aoyu'
AWS_REGION='us-east-1'
AWS_ECR=002224604296.dkr.ecr.us-east-1.amazonaws.com
repoName=news-action-data-clean

IMAGEURI=${AWS_ECR}/$repoName:latest

aws ecr create-repository $AWS_PROFILE \
  --repository-name $repoName \
  --image-scanning-configuration scanOnPush=true \
  --region $AWS_REGION >/dev/null 2>&1

BASE_ECR=173754725891.dkr.ecr.us-east-1.amazonaws.com/sagemaker-spark-processing

aws ecr get-login-password ${AWS_PROFILE} --region ${AWS_REGION} | docker login --username AWS --password-stdin ${BASE_ECR}

docker build -t $repoName .

docker tag $repoName:latest ${IMAGEURI}

echo ${IMAGEURI}

aws ecr get-login-password ${AWS_PROFILE} --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ECR}

docker push ${IMAGEURI}
