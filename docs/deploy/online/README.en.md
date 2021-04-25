---
title: Deploy The Online Part
weight: 3
---

In this step, you will deploy Recommender System Online part, including creating infrastructure and deploying services.

## Create infrastructure
1. Go to /home/ec2-user/environment/rs-workshop/scripts directory

```sh
cd /home/ec2-user/environment/rs-workshop/scripts
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

```sh
kubectl get node
```

The console looks like below:

TODO picture

## Deploy recommender system online services


