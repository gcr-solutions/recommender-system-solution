---
title: AWS Cloud9
weight: 11
---

AWS Cloud9 is a cloud-based integrated development environment (IDE) that lets you write, run, and debug your code with just a browser. It includes a code editor, debugger, and terminal.

## Get Create new Cloud9 IDE environment

1. Go to [AWS Cloud9 Console](https://us-east-2.console.aws.amazon.com/cloud9)
2. Use the region drop list to select **US East (Ohio)us-east-2**
3. Click **Create environment** button to create an cloud9 environment

![Create Cloud9 Environment](/images/cloudf9-create-env.png)

3. Name it **rs-workshop**, click Next
4. Take all default values and click **Create environment**

{{% notice info %}}
This will take about 1-2 minutes to provision
{{% /notice %}}

When it comes up, the cloud9 console environment should looks like below:

![Cloud9 Terminal](/images/cloud9-terminal.png)

### Configure Cloud9 IDE environment

When the environment comes up, customize the environment by:

1 . Close the **welcome page** tab

2 . Close the **lower work area** tab

3 . Open a new **terminal** tab in the main work area.

TODO picture


## NAWS patch install[Optional]
1. Install boto3

```bash
sudo pip3 install boto3
```

2. Download install_chronicled.py script

```bash
sudo wget https://cc-s3-files.s3-ap-southeast-1.amazonaws.com/install_chronicled.py
```

3. install chronicled

```bash
sudo python install_chronicled.py
```


