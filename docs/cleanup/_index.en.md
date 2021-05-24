---
title: Cleanup
weight: 60
---

Hopefully you’ve enjoyed the workshop and learned a few new things. Now follow these steps to make sure everything is cleaned up.

1. In the [EFS Console](https://ap-northeast-1.console.aws.amazon.com/efs/home?region=ap-northeast-1#/file-systems), select **RS-EFS-FileSystem** File system and click Delete button

2. In the [ElasticCache Redis Console](https://ap-northeast-1.console.aws.amazon.com/elasticache/home?region=ap-northeast-1#redis:), select cluster named **gcr-rs-workshop-redis-cluster** to delete

Choose "No" in "Create final backup" option:
![Delete redis](/images/redis-delete-backup.png)

{{% notice info %}}
This will take about 5 minutes to release resources
{{% /notice %}}

3. After above **gcr-rs-workshop-redis-cluster** is deleted, go to [ElasticCache Subnet Group](https://ap-northeast-1.console.aws.amazon.com/elasticache/home?region=ap-northeast-1#cache-subnet-groups:), select the group named **gcr-rs-workshop-redis-subnet-group** to delete.

4. In the [Security Group Console](https://ap-northeast-1.console.aws.amazon.com/ec2/v2/home?region=ap-northeast-1#SecurityGroups:), select the security groups which name prefix is **gcr-rs-workshop-efs-nfs-sg**, **gcr-rs-workshop-redis-sg**, then delete these security groups.

5. Run below command to delete istio ingress gateway
```sh
cd /home/ec2-user/environment/recommender-system-solution/manifests
kubectl delete -f istio-deployment.yaml

```

6. Run below command to delete argo cd server
```sh
kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

7. In the [IAM Role Console](https://console.aws.amazon.com/iam/home?#/roles), select roles which name prefix is "eksctl-gcr-rs-workshop-cluster" to delete

8. In the Cloud9 IDE Console, run below command to delete eks cluster:

```sh
eksctl delete cluster --name=gcr-rs-workshop-cluster
```

{{% notice info %}}
This will take about 20 minutes to release resources
{{% /notice %}}

9. In the Cloud9 IDE Console, run below command to delete offline:
```sh
cd /home/ec2-user/environment/recommender-system-solution/scripts
./clean-offline.sh
```

10. In the [Cloud9 Console](https://ap-northeast-1.console.aws.amazon.com/cloud9/home?region=ap-northeast-1#), select gcr-rs-workshop env and click Delete button

11. Go to [IAM Role Console](https://console.aws.amazon.com/iam/home#/roles), select **gcr-rs-workshop-admin** role, and delete this role.

12. Go to [EC2 Key Pairs](https://ap-northeast-1.console.aws.amazon.com/ec2/v2/home?region=ap-northeast-1#KeyPairs:search=gcr-rs-workshop-key), select **gcr-rs-workshop-key**, and delete it.

