#!/bin/bash
set -e

export EKS_CLUSTER=rs-beta

# 1. Create EKS Cluster
# # 1.1 Provision EKS cluster 
eksctl create cluster -f ./eks/nodes-config.yaml

# # 1.2 Create EKS cluster namespace
kubectl apply -f ../manifests/rs-ns.yaml

# 2. Install Istio with default profile
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.9.1 TARGET_ARCH=x86_64 sh -
cd istio-1.9.1/bin
./istioctl operator init
kubectl create ns istio-system
kubectl apply -f - <<EOF
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  namespace: istio-system
  name: default-istiocontrolplane
spec:
  profile: default
EOF
cd ../../

# 3. Create EFS
# 3.1 Find vpc id, vpc cidr, subnet ids
EKS_VPC_ID=$(aws eks describe-cluster --name $EKS_CLUSTER --query "cluster.resourcesVpcConfig.vpcId" --output text)
EKS_VPC_CIDR=$(aws ec2 describe-vpcs --vpc-ids $EKS_VPC_ID --query "Vpcs[].CidrBlock" --output text)
SUBNET_IDS=$(aws ec2 describe-instances --filters Name=vpc-id,Values=$EKS_VPC_ID --query \
  'Reservations[*].Instances[].SubnetId' \
  --output text)

echo $EKS_VPC_ID
echo $EKS_VPC_CIDR
echo $SUBNET_IDS

# 3.2 Install EFS CSI driver 
kubectl apply -k "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/ecr/?ref=release-1.1"

# 3.3 Create EFS
EFS_ID=$(aws efs create-file-system \
  --performance-mode generalPurpose \
  --throughput-mode bursting \
  --tags Key=Name,Value=RS-EFS-FileSystem \
  --encrypted |jq '.FileSystemId' -r)

echo EFS_ID: $EFS_ID

# 3.4 Create NFS Security Group
NFS_SECURITY_GROUP_ID=$(aws ec2 create-security-group --group-name efs-nfs-sg \
  --description "Allow NFS traffic for EFS" \
  --vpc-id $EKS_VPC_ID |jq '.GroupId' -r)

echo NFS_SECURITY_GROUP_ID: $NFS_SECURITY_GROUP_ID

# 3.5 add ingress rule for NFS_SECURITY_GROUP_ID before next steps
aws ec2 authorize-security-group-ingress --group-id $NFS_SECURITY_GROUP_ID \
  --protocol tcp \
  --port 2049 \
  --cidr $EKS_VPC_CIDR

sleep 2m  

# 3.6 Create EFS mount targets
for subnet_id in `echo $SUBNET_IDS`
do
  aws efs create-mount-target \
    --file-system-id $EFS_ID \
    --subnet-id $subnet_id \
    --security-group $NFS_SECURITY_GROUP_ID
done

# 3.7 Apply & create PV/StorageClass
cd ../manifests/efs
cp csi-env.yaml csi-env.yaml.bak
sed -i 's/FILE_SYSTEM_ID/'"$EFS_ID"'/g' csi-env.yaml
cat csi-env.yaml
kustomize build . |kubectl apply -f - 
mv csi-env.yaml.bak csi-env.yaml
cd ../../scripts

# 4 Create redis elastic cache, Provision Elasticache - Redis / Cluster Mode Disabled
# 4.1 Create subnet groups
ids=`echo $SUBNET_IDS | xargs -n1 | sort -u | xargs \
    aws elasticache create-cache-subnet-group \
    --cache-subnet-group-name "rs-redis-subnet-group" \
    --cache-subnet-group-description "rs-redis-subnet-group" \
    --subnet-ids`
echo $ids

CACHE_SUBNET_GROUP_NAME=$(echo $ids |jq '.CacheSubnetGroup.CacheSubnetGroupName' -r)
echo $CACHE_SUBNET_GROUP_NAME

# 4.2 Create redis security group
REDIS_SECURITY_GROUP_ID=$(aws ec2 create-security-group --group-name rs-redis-sg \
  --description "Allow traffic for Redis" \
  --vpc-id $EKS_VPC_ID|jq '.GroupId' -r)
echo $REDIS_SECURITY_GROUP_ID

# 4.3 config security group port
aws ec2 authorize-security-group-ingress --group-id $REDIS_SECURITY_GROUP_ID \
  --protocol tcp \
  --port 6379 \
  --cidr $EKS_VPC_CIDR 

# 4.4 create elastic cache redis
aws elasticache create-cache-cluster \
  --cache-cluster-id rs-redis-cluster \
  --cache-node-type cache.r6g.xlarge \
  --engine redis \
  --engine-version 6.x \
  --num-cache-nodes 1 \
  --cache-parameter-group default.redis6.x \
  --security-group-ids $REDIS_SECURITY_GROUP_ID \
  --cache-subnet-group-name $CACHE_SUBNET_GROUP_NAME