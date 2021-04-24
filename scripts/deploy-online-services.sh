# 1 update config
# 1.1 update redis config
REDIS_ENDPOINT=$(aws elasticache describe-cache-clusters --cache-cluster-id rs-redis-cluster --show-cache-node-info \
--query "CacheClusters[].CacheNodes[].Endpoint.Address" --output text)
cd ../manifests
sed -i 's/REDIS_HOST_PLACEHOLDER/'"$REDIS_ENDPOINT"'/g' config.yaml

# 2 Deploy services
# 1 setup argocd
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# 3 create application
VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')

curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64

sudo curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/v2.0.1/argocd-linux-amd64

sudo chmod +x /usr/local/bin/argocd

argocd app create gcr-recommender-system --repo https://github.com/gcr-solutions/recommender-system-solution.git --path manifestsk --dest-namespace 
rs-beta --dest-server https://kubernetes.default.svc --kustomize-image gcr.io/heptio-images/ks-guestbook-demo:0.1

# 4 get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d