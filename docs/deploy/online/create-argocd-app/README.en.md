---
title: Create Argo cd application
weight: 3
---

In this step, you will create Argo CD application to deploy all online services into EKS cluster

1. Go to /home/ec2-user/environment/recommender-system-solution/scripts directory

```sh
cd /home/ec2-user/environment/recommender-system-solution/scripts
```

2. Run below command to create and deploy online part:=

```sh
./create-argocd-application.sh
```

After about ~1 minutes, the console will output as below:

![Argocd create application](/images/argocd-create-app.png)

3. Access argo cd portal to check services deployment status, it should like below:

![Argocd application status](/images/argocd-app-status.png)

4. Access recommender system demo ui to verify services have been deployed successfully

Get ui endpoint:

```sh
./get-ingressgateway-elb-endpoint.sh
```

Access ui through browser, it should like below:

![Demo UI](/images/demo-ui.png)




