---
title: Create Argo cd application
weight: 3
---

In this step, you will create Argo CD application to deploy all online services into EKS cluster

1. Go to /home/ec2-user/environment/recommender-system-solution/scripts directory

```sh
cd /home/ec2-user/environment/recommender-system-solution/scripts
```

2. Run below command to login argo cd server from console:
{{% notice info %}}
Please replace with **DNS Name**, and input **User name** and **Password**. Refer [Setup argocd server in eks cluster](../argocd-server/readme) section to get **DNS Name**, **User name** and **Password**
{{% /notice %}}

```sh
argocd --insecure login <argo cd elb dns name>:443
```
example: argocd --insecure login add52b9be011a48e8959838ae16e41f5-178187690.ap-northeast-1.elb.amazonaws.com:443

![Argocd cli login](/images/argocd-cli-login.png)

2. Run the below command to create argo cd application

```sh
./create-argocd-application.sh
```
After about ~1 minutes, the console will output as below:

![Argocd create application](/images/argocd-create-app.png)

3. Access argo cd portal to sync application (we disable the "Auto Sync" option)

![Argocd application sync](/images/argocd-app-sync.png)

Click **SYNC** button and **SYNCHRONIZE** button

Then click **gcr-recommender-system** to view app detail like below:

![Argocd application status](/images/argocd-app-status.png)

There are some services deployed failed, because some config is not correct for your env, we will sync local config in next section.

