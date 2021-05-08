---
title: AWS Cloud9
weight: 1
---

AWS Cloud9 is a cloud-based integrated development environment (IDE) that lets you write, run, and debug your code with just a browser. It includes a code editor, debugger, and terminal.

## Create new Cloud9 IDE environment

1. If you don’t already have an AWS account with Administrator access: [create one now by clicking here](https://aws.amazon.com/getting-started/)
2. Go to [AWS Cloud9 Console](https://ap-northeast-1.console.aws.amazon.com/cloud9)
2. Use the region drop list to select **Asia Pacific (Tokyo)ap-northeast-1**
3. Click **Create environment** button to create an cloud9 environment

![Create Cloud9 Environment](/images/create-cloud9-start.png)

3. Name it **gcr-rs-workshop**, click Next
4. Take all default values and click **Create environment**

{{% notice info %}}
This will take about 1-2 minutes to provision
{{% /notice %}}

When it comes up, the cloud9 console environment should looks like below:

![Cloud9 Welcome](/images/cloud9-welcome.png)

### Configure Cloud9 IDE environment

When the environment comes up, customize the environment by:

1 . Close the **welcome page** tab, close the **Quick Start** tab, close **lower work area** tab

![Cloud9 Close](/images/cloud9-close.png)

3 . Open a new **terminal** tab in the main work area.

![Cloud9 Open Terminal](/images/cloud9-open-terminal.png)

## NAWS patch install [Optional]
In the Cloud9 terminal, run the below commands to install chronicled

1. Install boto3

```bash
sudo pip3 install boto3
```

2. Download install_chronicled.py script

```bash
sudo wget https://raw.githubusercontent.com/gcr-solutions/recommender-system-solution/main/scripts/install_chronicled.py
```

3. install chronicled

```bash
sudo python install_chronicled.py
```


