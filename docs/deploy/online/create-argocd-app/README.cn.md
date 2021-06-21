---
title: 创建 Argo CD 应用
weight: 3
---

在本节中，您将创建 Argo CD 应用程序用来将所有在线服务全部部署到 EKS 集群中 

1. 跳转到 /home/ec2-user/environment/recommender-system-solution/scripts 目录

```sh
cd /home/ec2-user/environment/recommender-system-solution/scripts
```

2. 运行以下命令来创建和部署在线部分：

```sh
./create-argocd-application.sh
```

大约 1 分钟后，控制台的输出如下所示： 

![Argocd create application](/images/argocd-create-app.png)

3. 访问 Argo CD 网站并检查服务部署状态。 **请确保所有的状态都变成绿色后，再执行之后的步骤！！**： 

![Argocd application status](/images/argocd-app-status.png)

4. 将数据加载到系统中。

```sh
cd /home/ec2-user/environment/recommender-system-solution/scripts

./load-seed-data.sh
```

5. 获取 GUI 端点URL： 

```sh
./get-ingressgateway-elb-endpoint.sh
```

通过端点URL访问应用网站，界面应该如下图所示： 

![Demo UI](/images/demo-ui.png)

恭喜你！ 推荐系统部署成功！！ 



