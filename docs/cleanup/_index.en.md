---
title: Cleanup
weight: 60
---

Hopefully you’ve enjoyed the workshop and learned a few new things. Now follow these steps to make sure everything is cleaned up.

1. In the [Load Balancer Console](https://ap-northeast-1.console.aws.amazon.com/ec2/v2/home?region=us-east-2#LoadBalancers:sort=loadBalancerName), select the load balancer which "Tags" Key is "kubernetes.io/cluster/rs-beta", then delete them.

2. In the [EFS Console](https://ap-northeast-1.console.aws.amazon.com/efs/home?region=ap-northeast-1#/file-systems), select **RS-EFS-FileSystem** File system and click Delete button

3. In the [ElasticCache Redis Console](https://ap-northeast-1.console.aws.amazon.com/elasticache/home?region=ap-northeast-1#redis:), select cluster named **gcr-rs-workshop-redis-cluster** to delete

4. In the [ElasticCache Subnet Group](https://ap-northeast-1.console.aws.amazon.com/elasticache/home?region=ap-northeast-1#cache-subnet-groups:), select the group named **gcr-rs-workshop-redis-subnet-group** to delete.

5. In the [Security Group Console](https://ap-northeast-1.console.aws.amazon.com/ec2/v2/home?region=ap-northeast-1#SecurityGroups:), select the security groups named **gcr-rs-workshop-efs-nfs-sg**, **gcr-rs-workshop-redis-sg** to delete them.  TODO

6. In the [IAM Role Console](https://console.aws.amazon.com/iam/home?#/roles), select roles which name prefix is "eksctl-rs-beta" to delete

7. In the Cloud9 IDE Console, run below command to delete eks cluster:

```sh
eksctl delete cluster --name=rs-beta
```

{{% notice info %}}
This will take about ~20 minutes to release resources
{{% /notice %}}

