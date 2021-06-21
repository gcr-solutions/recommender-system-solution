---
title: 创建基础设施
weight: 1
---

在此步骤中，您将创建推荐系统在线部分的基础设施

1. 跳转到 /home/ec2-user/environment/recommender-system-solution/scripts 目录

```sh
cd /home/ec2-user/environment/recommender-system-solution/scripts
```

2. 运行下面的命令来创建基础设施，包括： 
- eks cluster
- istio
- efs
- elastic cache(redis)

```sh
./create-online-infra.sh
```

{{% notice info %}}
这将需要大约 30 分钟进行配置 
{{% /notice %}}

3. 验证基础设施是否创建成功： 

- 若 EFS 创建成功，控制台输出应如下所示： 

![Verify EKS nodes](/images/check-efs.png)

- 若 redis 创建成功，控制台输出如下： 
![Verify EKS nodes](/images/check-redis.png)

- 输入以下命令验证EKS节点创建成功。控制台应显示有两个节点，并且节点状态为Ready：
```sh
kubectl get node
```

![Verify EKS nodes](/images/check-eks-nodes.png)