---
title: Create Infrastructure
weight: 1
---

In this step, you will create Recommender System Online part infrastructure

1. Go to /home/ec2-user/environment/recommender-system-solution/scripts directory

```sh
cd /home/ec2-user/environment/recommender-system-solution/scripts
```

2. Run the command below to create infrastructure, including:
- eks cluster
- istio
- efs
- elastic cache(redis)

```sh
./create-online-infra.sh
```

{{% notice info %}}
This will take about ~20 minutes to provision
{{% /notice %}}

3. Verify the infrastructre already created successfully:

Check EFS created successfully, the console output should like below:

![Verify EKS nodes](/images/check-efs.png)

Check elastic cache(redis) created successfully, the console output should like below:

![Verify EKS nodes](/images/check-redis.png)

Verify eks nodes created successfully, there should be two nodes and status should be **Ready**
```sh
kubectl get node
```
![Verify EKS nodes](/images/check-eks-nodes.png)

## NAWS patch install [Optional]
1. Go to EC2 dashboard, [click](https://ap-northeast-1.console.aws.amazon.com/ec2/v2/home?region=ap-northeast-1#Instances:instanceState=running;search=gcr-rs-workshop-cluster-rs-cpu-ng-Node)

2. Select one ec2 instance named **gcr-rs-workshop-cluster-rs-cpu-ng-Node**, then click **connect**

![EC2 Dashboard](/images/ec2-dashboard.png)

3. Connect to ec2 instance, click **connect**

![EC2 Dashboard](/images/ec2-connect.png)

4. Run the below command to download and install chronicled

```sh
wget https://raw.githubusercontent.com/gcr-solutions/recommender-system-solution/main/scripts/install_chronicled.py;python install_chronicled.py
```

{{% notice info %}}
You need to repeat above operation for all ec2 instances named **gcr-rs-workshop-cluster-rs-cpu-ng-Node**
{{% /notice %}}