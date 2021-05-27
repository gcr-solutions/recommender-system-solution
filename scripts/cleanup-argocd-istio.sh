#!/bin/bash
set -e

# cd /home/ec2-user/environment/recommender-system-solution/manifests
# kubectl delete -f istio-deployment.yaml

# kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# sleep 10

# echo 'check related resources have been cleaned up'

i=0
while [ $i -le 3 ]
do
  ISTIO_SG_ID=$(aws ec2 describe-security-groups --filter Name=tag:kubernetes.io/cluster/gcr-rs-workshop-cluster,Values=owned Name=description,Values=*istio-system/istio-ingressgateway* --query "SecurityGroups[*].[GroupId]" --output text)
  if [ "$ISTIO_SG_ID" == "" ];
  	echo "delete istio security group successfully!"
    break
  sleep 3
  let i++
done

j=0
while [ $j -le 3 ]
do
  ARGOCD_SG_ID=$(aws ec2 describe-security-groups --filter Name=tag:kubernetes.io/cluster/gcr-rs-workshop-cluster,Values=owned Name=description,Values=*argocd/argocd-server* --query "SecurityGroups[*].[GroupId]" --output text)
  if [ "$ARGOCD_SG_ID" == "" ];
  	echo "delete argocd security group successfully!"
    break
  sleep 3    
  let j++
done

echo $ISTIO_SG_ID
echo $ARGOCD_SG_ID

# ISTIO_SG_ID=$(aws ec2 describe-security-groups --filter Name=tag:kubernetes.io/cluster/gcr-rs-workshop-cluster,Values=owned Name=description,Values=*istio-system/istio-ingressgateway* --query "SecurityGroups[*].[GroupId]" --output text)

# aws ec2 describe-security-groups --filter Name=tag:kubernetes.io/cluster/gcr-rs-workshop-cluster,Values=owned Name=description,Values=*argocd/argocd-server*

