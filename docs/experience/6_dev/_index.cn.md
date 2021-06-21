---
title: 持续优化
weight: 46
---

推荐系统通过集成 Argo CD 实现持续部署的功能。 本节包括以下步骤： 
1. 在 kustomization.yaml 中更改 docker 镜像标签 
2. 将 kustomization.yaml 同步到 argo cd。 
3. 检查新的docker镜像是否部署完成
   
1 . 更改 docker 镜像标签:
```sh
cd /home/ec2-user/environment/recommender-system-solution/manifests

sed -i 's/latest/'cd-test'/g' kustomization.yaml
```

2 . 同步 kustomization.yaml 到 Argo CD

```sh
argocd app sync gcr-recommender-system --local /home/ec2-user/environment/recommender-system-solution/manifests
```

3 . 您应该可以看到 Argo CD 服务在重新部署： 

![CD Test](/images/cd-test.png)




