# 1 login argo cd server
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

elb_names=($(aws elb describe-load-balancers --output text | grep LOADBALANCERDESCRIPTIONS |  awk '{print $6 }'))

echo "find $#elb_names elbs"

argocdserver_elb=''
for elb in ${elb_names[@]};
do
  echo "check elb $elb ..."
  aws elb describe-tags --load-balancer-name $elb --output text  | grep 'argocd-server'
  if [[ $? -eq '0' ]];then
     echo "find argocd-server $elb"
     argocdserver_elb=$elb
     break
  fi
done

endpoint=$(aws elb describe-load-balancers --load-balancer-name $argocdserver_elb --output text | grep LOADBALANCERDESCRIPTIONS | awk '{print $2 }')

echo user name: admin
echo password: $ARGOCD_PASSWORD
echo endpoint: $endpoint

argocd --insecure login $endpoint:443 --username admin --password $ARGOCD_PASSWORD

# 2 update lambda env

echo "update-lambda-env"
./update-lambda-env.sh


# 3 Create argocd application
argocd app create gcr-recommender-system --repo https://github.com/gcr-solutions/recommender-system-solution.git --path manifests --dest-namespace \
rs-beta --dest-server https://kubernetes.default.svc --kustomize-image gcr.io/heptio-images/ks-guestbook-demo:0.1

sleep 20

# 4 Sync local config
# 1 update config
# 1.1 update redis config
REDIS_ENDPOINT=$(aws elasticache describe-cache-clusters --cache-cluster-id gcr-rs-workshop-redis-cluster --show-cache-node-info \
--query "CacheClusters[].CacheNodes[].Endpoint.Address" --output text)
cd ../manifests
sed -i 's/REDIS_HOST_PLACEHOLDER/'"$REDIS_ENDPOINT"'/g' config.yaml

if [[ -z $REGION ]];then
    REGION='ap-northeast-1'
fi

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

if [[ $? -ne 0 ]]; then
  echo "error!!! can not get your AWS_ACCOUNT_ID"
  exit 1
fi

echo "REGION: $REGION"
echo "ACCOUNT_ID: $ACCOUNT_ID"

cat config.yaml | sed 's/__AWS_REGION__/'"$REGION"'/g' > config_1.yaml
cat config_1.yaml | sed 's/__AWS_ACCOUNT_ID__/'"$ACCOUNT_ID"'/g' >  config.yaml
rm config_1.yaml

cat config.yaml
sleep 10

# sync the local config to argocd

argocd app sync gcr-recommender-system --local /home/ec2-user/environment/recommender-system-solution/manifests


