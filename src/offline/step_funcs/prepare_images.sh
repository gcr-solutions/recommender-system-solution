
if [[ -z $REGION ]];then
    REGION='ap-northeast-1'
fi

echo REGION=$REGION
AWS_REGION=$REGION

account_id=$(aws sts get-caller-identity --query Account --output text)

if [[ $? -ne 0 ]]; then
      echo "error!!!"
      exit 1
fi

account_ecr_uri=${account_id}.dkr.ecr.${AWS_REGION}.amazonaws.com

echo "account_id: $account_id"

offline_images=(
rs/news-action-preprocessing
rs/news-add-item-user-batch
rs/news-dashboard
rs/news-filter-batch
rs/news-inverted-list
rs/news-item-feature-update-batch
rs/news-item-preprocessing
rs/news-model-update-action-gpu
rs/news-model-update-embedding-gpu
rs/news-portrait-batch
rs/news-rank-batch
rs/news-recall-batch
rs/news-weight-update-batch
)

ECR_PREFIX=public.ecr.aws/t8u1z3c8

for image_name in  ${offline_images[@]};
do
  echo ""
  echo ">> docker image: $ECR_PREFIX/$image_name"

  docker pull $ECR_PREFIX/$image_name
  if [[ $? -ne 0 ]]; then
      echo "error!!!"
      exit 1
  fi
  docker tag $ECR_PREFIX/$image_name  ${account_ecr_uri}/$image_name

  aws ecr create-repository  \
  --repository-name $image_name \
  --image-scanning-configuration scanOnPush=true \
  --region $AWS_REGION >/dev/null 2>&1

  aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${account_ecr_uri}
  docker push ${account_ecr_uri}/$image_name
  if [[ $? -ne 0 ]]; then
      echo "error!!!"
      exit 1
  fi
done



