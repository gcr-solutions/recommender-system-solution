#!/bin/bash
set -e

# cd /home/ec2-user/environment/recommender-system-solution/manifests
# kubectl delete -f istio-deployment.yaml

# kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# sleep 10

echo "start check istio ingress gateway security group"
i=1
ISTIO_SG_ID=""
while [ $i -le 3 ]
do
  ISTIO_SG_ID=$(aws ec2 describe-security-groups --filter Name=tag:kubernetes.io/cluster/gcr-rs-workshop-cluster,Values=owned Name=description,Values=*istio-system/istio-ingressgateway* --query "SecurityGroups[*].[GroupId]" --output text)
  if [ "$ISTIO_SG_ID" == "" ];then
    echo "delete istio security group successfully!"
    break
  else
    echo "wait for wait for istio security group deleted!"    
  fi
  sleep 3
  let i++
done

echo "start check argocd server security group"
j=1
ARGOCD_SG_ID=""
while [ $j -le 3 ]
do
  ARGOCD_SG_ID=$(aws ec2 describe-security-groups --filter Name=tag:kubernetes.io/cluster/gcr-rs-workshop-cluster,Values=owned Name=description,Values=*argocd/argocd-server* --query "SecurityGroups[*].[GroupId]" --output text)
  if [ "$ARGOCD_SG_ID" == "" ];then
    echo "delete argocd security group successfully!"
    break
  else
    echo "wait for wait for argocd server security group deleted!"
  fi
  sleep 3
  let j++
done

echo $ISTIO_SG_ID
echo $ARGOCD_SG_ID

if [ "$ISTIO_SG_ID" != "" ];then
  echo "delete istio security group!"
  aws ec2 delete-security-group --group-id $ISTIO_SG_ID
fi

if [ "$ARGOCD_SG_ID" != "" ];then
  echo "delete argocd security group!"
  aws ec2 delete-security-group --group-id $ARGOCD_SG_ID
fi
