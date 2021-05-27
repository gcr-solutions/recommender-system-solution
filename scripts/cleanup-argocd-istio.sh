#!/bin/bash
set -e

# cd /home/ec2-user/environment/recommender-system-solution/manifests
# kubectl delete -f istio-deployment.yaml

# kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# sleep 10

# echo 'check related resources have been cleaned up'

echo "start check istio ingress gateway security group"
i=1
while [ $i -le 3 ]
do
  ISTIO_SG_ID=$(aws ec2 describe-security-groups --filter Name=tag:kubernetes.io/cluster/gcr-rs-workshop-cluster,Values=owned Name=description,Values=*istio-system/istio-ingressgateway* --query "SecurityGroups[*].[GroupId]" --output text)
  if [ "$ISTIO_SG_ID" == "" ];then
    echo "delete istio security group successfully!"
    break
  fi
  sleep 3
  let i++
done

echo "start check argocd server security group"
j=0
while [ $j -le 3 ]
do
  ARGOCD_SG_ID=$(aws ec2 describe-security-groups --filter Name=tag:kubernetes.io/cluster/gcr-rs-workshop-cluster,Values=owned Name=description,Values=*argocd/argocd-server* --query "SecurityGroups[*].[GroupId]" --output text)
  if [ "$ARGOCD_SG_ID" == "" ];then
  	echo "delete argocd security group successfully!"
    break
  fi
  sleep 3
  let j++
done

echo $ISTIO_SG_ID
echo $ARGOCD_SG_ID