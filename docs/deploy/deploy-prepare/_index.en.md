---
title: Prepare deploy scripts
weight: 10
---

In this section, you'll need to prepare deploy script

1. Open the Cloud9 IDE created in prerequisite section and go to /home/ec2-user/environment/rs-workshop directory

```bash
cd /home/ec2-user/environment/rs-workshop
```

2. Download scripts from our public bucket

```bash
aws s3 cp s3://aws-gcr-rs-sol-workshop/rs-workshop.tar.gz ./
```

3. Decompress the .gz file
```bash
tar -zxvf rs-workshop.tar.gz
```

