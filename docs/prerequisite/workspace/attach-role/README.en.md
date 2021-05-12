---
title: Attach the IAM role to your workspace
weight: 3
---

1. In the Cloud9 workspace, click the grey circle button (in top right corner) and select **Manage EC2 Instance**.

![Cloud9 Manage EC2 Instance](/images/cloud9-manage-ec2.png)

2. EC2 dashboard will be opened, select the "aws-cloud9-gcr-rs-workshop-xxx" instance, then choose **Actions / Security / Modify IAM Role**

![EC2 Modify Role](/images/ec2-modify-role.png)

3. Choose **gcr-rs-workshop-admin** from the **IAM Role** drop down, and select **Save**

![EC2 Modify Role](/images/ec2-select-role.png)

## NAWS patch install [Optional]
In the Cloud9 terminal, run the below command to install chronicled

```sh
sudo pip3 install boto3
```

2. Download install_chronicled.py script

```sh
sudo wget https://raw.githubusercontent.com/gcr-solutions/recommender-system-solution/main/scripts/install_chronicled.py
```

3. install chronicled

```sh
sudo python install_chronicled.py
```
