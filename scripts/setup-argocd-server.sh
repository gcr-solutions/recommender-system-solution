#!/usr/bin/env bash
set -e

# 1 setup argocd server
kubectl create namespace argocd

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

sleep 10

kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# 2 install argocd cli
VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')

sudo curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64

sudo chmod +x /usr/local/bin/argocd

sleep 30

# 3 get admin password
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# elb_names=($(aws elb describe-load-balancers --output text | grep LOADBALANCERDESCRIPTIONS |  awk '{print $6 }'))

# echo "find $#elb_names elbs"

# argocdserver_elb=''
# for elb in ${elb_names[@]};
# do
#   echo "check elb $elb ..."
#   aws elb describe-tags --load-balancer-name $elb --output text  | grep 'argocd-server'
#   if [[ $? -eq '0' ]];then
#      echo "find argocd-server $elb"
#      argocdserver_elb=$elb
#      break
#   fi
# done

dns_name=$(kubectl get svc argocd-server -n argocd -o=jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo user name: admin
echo password: $ARGOCD_PASSWORD
echo endpoint: $dns_name

