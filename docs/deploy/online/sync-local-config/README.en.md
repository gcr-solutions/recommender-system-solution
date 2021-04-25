---
title: Sync local config to argo cd application
weight: 3
---

In this step, you will update and sync local config to argo cd config

1. Go to /home/ec2-user/environment/recommender-system-solution/scripts directory

```sh
cd /home/ec2-user/environment/recommender-system-solution/scripts
```

2. Run below command to update and sync local config to argo cd config:

```sh
./update-services-config.sh 
```

Wait for about 1 minute, then we can go to argo cd portal to check application, all services should be deployed successfully.

