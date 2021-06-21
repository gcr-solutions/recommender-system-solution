---
title: Environment
weight: 10
---

## AWS Account
In order to complete this workshop you’ll need an AWS Account with Administrator Access role. If you don’t have, create one now by clicking [here](https://aws.amazon.com/getting-started/)

**Cost**: Some, but NOT all, of the resources you will launch as part of this workshop are eligible for the AWS free tier if your account is less than 12 months old. See the [AWS Free Tier page](https://aws.amazon.com/free/) for more details. To avoid charges for endpoints and other resources you might not need after you’ve finished a workshop, please refer to the **Cleanup Module**

## AWS Region
Once you’ve chosen a region, you should create all of the resources for this workshop there. Accordingly, we recommend running this workshop in **Tokyo** AWS Regions. Use the region drop list to select **Asia Pacific (Tokyo)ap-northeast-1**.

## Browser
We recommend you use the latest version of **Chrome** to complete this workshop.

## AWS Command Line Interface
To complete certain workshop modules, you’ll need the AWS Command Line Interface (CLI) and a Bash environment. You’ll use the AWS CLI to interface with AWS services.

For these workshops, AWS Cloud9 is used to avoid problems that can arise configuring the CLI on your machine. AWS Cloud9 is a cloud-based integrated development environment (IDE) that lets you write, run, and debug your code with just a browser. It has the AWS CLI pre-installed so you don’t need to install files or configure your laptop to use the AWS CLI. For Cloud9 setup directions for these workshops, see **Cloud9 Setup**. Do NOT attempt to use a locally installed AWS CLI during a live workshop because there is insufficient time during a live workshop to resolve related issues.

## SageMaker Resource Requirement
To test certain workshop functions, your SageMaker resource limit need to meet the minimum requirement as below. Check and increase the SageMaker resource limit by clicking [here](https://sagemaker-tools.corp.amazon.com/limits)

|Region |Resource type |Resource | 	Required limit |
|--- |--- | --- | --- |
|ap-northeast-1|SageMaker Training |training-job/ml.p2.xlarge |2|
|ap-northeast-1|SageMaker Processing |processing-job/ml.m5.large |2|
