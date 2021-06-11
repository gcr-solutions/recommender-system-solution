#!/usr/bin/env bash
set -e

export EKS_CLUSTER=gcr-rs-workshop-cluster
EKS_VPC_ID=$(aws eks describe-cluster --name $EKS_CLUSTER --query "cluster.resourcesVpcConfig.vpcId" --output text)

echo "################ start clean online resources ################ "

echo "################ start clean EFS resource ################ "

#delete EFS file system
EFS_ID=$(aws efs describe-file-systems | jq '.[][] | select(.Tags[].Value=="GCR-RS-WORKSHOP-EFS-FileSystem")' | jq '.FileSystemId' -r)

MOUNT_TARGET_IDS=$(aws efs describe-mount-targets --file-system-id $EFS_ID | jq '.[][].MountTargetId' -r)
for MOUNT_TARGET_ID in `echo $MOUNT_TARGET_IDS`
do
  echo remove $MOUNT_TARGET_ID
  aws efs delete-mount-target --mount-target-id $MOUNT_TARGET_ID
done

echo remove EFS File System: $EFS_ID

aws efs delete-file-system --file-system-id $EFS_ID

# sleep 10

i=1
EFS_ID=""
while [ $i -le 20 ]
do
  EFS_ID=$(aws efs describe-file-systems | jq '.[][] | select(.Tags[].Value=="GCR-RS-WORKSHOP-EFS-FileSystem")' | jq '.FileSystemId' -r)
  if [ "$EFS_ID" == "" ];then
    echo "delete GCR-RS-WORKSHOP-EFS-FileSystem EFS successfully!"
    break
  else
    echo "wait for GCR-RS-WORKSHOP-EFS-FileSystem EFS deleted!"    
  fi
  sleep 10
  let i++
done

#delete EFS file system security group
NFS_SECURITY_GROUP_ID=$(aws ec2 describe-security-groups --filters Name=vpc-id,Values=$EKS_VPC_ID Name=group-name,Values=gcr-rs-workshop-efs-nfs-sg | jq '.SecurityGroups[].GroupId' -r)
echo $NFS_SECURITY_GROUP_ID

aws ec2 delete-security-group --group-name $NFS_SECURITY_GROUP_ID

# i=1
# NFS_SECURITY_GROUP_ID=""
# while [ $i -le 20 ]
# do
#   NFS_SECURITY_GROUP_ID=$(aws ec2 describe-security-groups --filters Name=vpc-id,Values=$EKS_VPC_ID Name=group-name,Values=gcr-rs-workshop-efs-nfs-sg | jq '.SecurityGroups[].GroupId' -r)
#   if [ "$NFS_SECURITY_GROUP_ID" == "" ];then
#     echo "delete gcr-rs-workshop-efs-nfs-sg security group successfully!"
#     break
#   else
#     echo "wait for gcr-rs-workshop-efs-nfs-sg security group deleted!"    
#   fi
#   sleep 10
#   let i++
# done

#delete Elastic Cache Redis
echo "################ start Elasticache Redis resources ################ "

aws elasticache delete-cache-cluster --cache-cluster-id gcr-rs-workshop-redis-cluster
i=1
ELASTIC_CACHE_CLUSTER=""
while [ $i -le 20 ]
do
  ELASTIC_CACHE_CLUSTER=$(aws elasticache describe-cache-clusters | jq '.CacheClusters[] | select(.CacheClusterId=="gcr-rs-workshop-redis-cluster")')
  if [ "$ELASTIC_CACHE_CLUSTER" == "" ];then
    echo "delete gcr-rs-workshop-redis-cluster successfully!"
    break
  else
    echo "wait for gcr-rs-workshop-redis-cluster deleted!"    
  fi
  sleep 10
  let i++
done

aws elasticache delete-cache-subnet-group --cache-subnet-group-name gcr-rs-workshop-redis-subnet-group

#delete REDIS Cache security group
REDIS_SECURITY_GROUP_ID=$(aws ec2 describe-security-groups --filters Name=vpc-id,Values=$EKS_VPC_ID Name=group-name,Values=gcr-rs-workshop-redis-sg | jq '.SecurityGroups[].GroupId' -r)
echo $REDIS_SECURITY_GROUP_ID

aws ec2 delete-security-group --group-name $REDIS_SECURITY_GROUP_ID

# i=1
# REDIS_SECURITY_GROUP_ID=""
# while [ $i -le 20 ]
# do
#   REDIS_SECURITY_GROUP_ID=$(aws ec2 describe-security-groups --filters Name=vpc-id,Values=$EKS_VPC_ID Name=group-name,Values=gcr-rs-workshop-redis-sg | jq '.SecurityGroups[].GroupId' -r)
#   if [ "$REDIS_SECURITY_GROUP_ID" == "" ];then
#     echo "delete gcr-rs-workshop-efs-nfs-sg security group successfully!"
#     break
#   else
#     echo "wait for gcr-rs-workshop-efs-nfs-sg security group deleted!"    
#   fi
#   sleep 10
#   let i++
# done

#clean argocd and istio resources
./cleanup-argocd-istio.sh

#remove eks cluster roles
echo "################ start Elasticache Redis resources ################ "

ROLE_NAMES=$(aws iam list-roles | jq '.[][].RoleName' -r | grep eksctl-gcr-rs-workshop-cluster*)
for ROLE_NAME in `echo $ROLE_NAMES`
do
  echo remove $ROLE_NAME
  aws iam delete-role --role-name $ROLE_NAME
done

#remove eks cluster
eksctl delete cluster --name=$EKS_CLUSTER








