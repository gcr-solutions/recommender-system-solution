# 1 update config
# 1.1 update redis config
REDIS_ENDPOINT=$(aws elasticache describe-cache-clusters --cache-cluster-id rs-redis-cluster --show-cache-node-info \
--query "CacheClusters[].CacheNodes[].Endpoint.Address" --output text)
cd ../manifests
sed -i 's/REDIS_HOST_PLACEHOLDER/'"$REDIS_ENDPOINT"'/g' config.yaml
sleep 10

# sync the local config to argocd

argocd app sync gcr-recommender-system --local /home/ec2-user/environment/recommender-system-solution/manifests

