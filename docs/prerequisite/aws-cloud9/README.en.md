---
title: AWS Cloud9 
weight: 1
---

AWS Cloud9 is a cloud-based integrated development environment (IDE) that lets you write, run, and debug your code with just a browser. It includes a code editor, debugger, and terminal.

## Get started with AWS Cloud9

1. Go to [AWS Cloud9 Console](https://us-east-2.console.aws.amazon.com/cloud9)
2. Click "Create environment" button to create an cloud9 environment
3. Name it **rs-workshop**, click Next
4. Take all default values and click **Create environment**

When it comes up, the cloud9 console environment should looks like below:
<picture>

## NAWS patch install[Optional]
1. Install boto3

    sudo pip3 install boto3

2. Download install_chronicled.py script

    sudo wget https://cc-s3-files.s3-ap-southeast-1.amazonaws.com/install_chronicled.py

3. install chronicled

    sudo python install_chronicled.py



