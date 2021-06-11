#!/usr/bin/env bash
set -e

export EKS_CLUSTER=gcr-rs-workshop-cluster
EKS_VPC_ID=$(aws eks describe-cluster --name $EKS_CLUSTER --query "cluster.resourcesVpcConfig.vpcId" --output text)

echo "################ start clean online resources ################ "

echo "################ start clean EFS resource ################ "

#delete EFS file system
EFS_ID=$(aws efs describe-file-systems | jq '.[][] | select(.Tags[].Value=="GCR-RS-WORKSHOP-EFS-FileSystem")' | jq '.FileSystemId' -r)
if [ "$EFS_ID" != "" ]; then
  MOUNT_TARGET_IDS=$(aws efs describe-mount-targets --file-system-id $EFS_ID | jq '.[][].MountTargetId' -r)
  for MOUNT_TARGET_ID in $(echo $MOUNT_TARGET_IDS); do
    echo remove $MOUNT_TARGET_ID
    aws efs delete-mount-target --mount-target-id $MOUNT_TARGET_ID
  done

  MOUNT_TARGET_IDS=""
  while true; do
    MOUNT_TARGET_IDS=$(aws efs describe-mount-targets --file-system-id $EFS_ID | jq '.[][].MountTargetId' -r)
    if [ "$MOUNT_TARGET_IDS" == "" ]; then
      echo "delete GCR-RS-WORKSHOP-EFS-FileSystem EFS mount target successfully!"
      break
    else
      echo "wait for GCR-RS-WORKSHOP-EFS-FileSystem EFS mount target deleted!"
    fi
    sleep 20
  done

  echo remove EFS File System: $EFS_ID

  aws efs delete-file-system --file-system-id $EFS_ID

  EFS_ID=""
  while true; do
    EFS_ID=$(aws efs describe-file-systems | jq '.[][] | select(.Tags[].Value=="GCR-RS-WORKSHOP-EFS-FileSystem")' | jq '.FileSystemId' -r)
    if [ "$EFS_ID" == "" ]; then
      echo "delete GCR-RS-WORKSHOP-EFS-FileSystem EFS successfully!"
      break
    else
      echo "deleting GCR-RS-WORKSHOP-EFS-FileSystem EFS!"
    fi
    sleep 20
  done
fi

#delete EFS file system security group
NFS_SECURITY_GROUP_ID=$(aws ec2 describe-security-groups --filters Name=vpc-id,Values=$EKS_VPC_ID Name=group-name,Values=gcr-rs-workshop-efs-nfs-sg | jq '.SecurityGroups[].GroupId' -r)

if [ "$NFS_SECURITY_GROUP_ID" != "" ]; then
  echo remove security group $NFS_SECURITY_GROUP_ID
  aws ec2 delete-security-group --group-id $NFS_SECURITY_GROUP_ID
fi

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
echo "################ start clean Elasticache Redis resources ################ "
ELASTIC_CACHE_CLUSTER=$(aws elasticache describe-cache-clusters | jq '.CacheClusters[] | select(.CacheClusterId=="gcr-rs-workshop-redis-cluster")')
if [ "$ELASTIC_CACHE_CLUSTER" != "" ]; then
  aws elasticache delete-cache-cluster --cache-cluster-id gcr-rs-workshop-redis-cluster
  while true; do
    ELASTIC_CACHE_CLUSTER=$(aws elasticache describe-cache-clusters | jq '.CacheClusters[] | select(.CacheClusterId=="gcr-rs-workshop-redis-cluster")')
    if [ "$ELASTIC_CACHE_CLUSTER" == "" ]; then
      echo "delete gcr-rs-workshop-redis-cluster successfully!"
      break
    else
      echo "deleting gcr-rs-workshop-redis-cluster!"
    fi
    sleep 20
  done
  aws elasticache delete-cache-subnet-group --cache-subnet-group-name gcr-rs-workshop-redis-subnet-group
fi

#delete REDIS Cache security group
REDIS_SECURITY_GROUP_ID=$(aws ec2 describe-security-groups --filters Name=vpc-id,Values=$EKS_VPC_ID Name=group-name,Values=gcr-rs-workshop-redis-sg | jq '.SecurityGroups[].GroupId' -r)
if [ "$REDIS_SECURITY_GROUP_ID" != "" ]; then
  echo delete redis security group $REDIS_SECURITY_GROUP_ID
  aws ec2 delete-security-group --group-id $REDIS_SECURITY_GROUP_ID
fi

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
# ./cleanup-argocd-istio.sh

#remove eks cluster roles
echo "################ start Elasticache Redis resources ################ "

ROLE_NAMES=$(aws iam list-roles | jq '.[][].RoleName' -r | grep eksctl-gcr-rs-workshop-cluster*)
for ROLE_NAME in $(echo $ROLE_NAMES); do
  echo detach $ROLE_NAME policy
  # aws iam delete-role --role-name $ROLE_NAME
  aws iam detach-role-policy --role-name $ROLE_NAME
done

#remove eks cluster
eksctl delete cluster --name=$EKS_CLUSTER
