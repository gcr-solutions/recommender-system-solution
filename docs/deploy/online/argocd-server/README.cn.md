---
title: 创建 Argo CD 服务器
weight: 2
---

在本节中，您将在 EKS 集群中创建 Argo CD 服务器 

1. 跳转到 /home/ec2-user/environment/recommender-system-solution/scripts 目录

```sh
cd /home/ec2-user/environment/recommender-system-solution/scripts
```

2. 运行以下命令在 eks 集群中设置 Argo CD 服务器 

```sh
./setup-argocd-server.sh
```
{{% notice info %}}
这将需要大约 1 分钟的时间进行配置 
{{% /notice %}}

控制台将输出 argocd 的**用户名**、**密码**和服务器**端点URL**，如下所示： 

![Argocd password](/images/argocd-password.png)

将**端点URL**复制到浏览器中访问 Argo CD 服务器网页，如果您是第一次访问此端点，请单击**Advanced**和**Proceed to ...** 

![Argocd First](/images/argocd-first.png)

![Argocd Second](/images/argocd-second.png)

输入**用户名**和**密码**，然后点击**登录**，网页应该如下图所示： 

![Argocd Signin](/images/argocd-signin.png)

![Argocd Second](/images/argocd-main-page.png)

Argo CD 服务器设置成功！!


