---
title: 检查环境
weight: 10
---

## AWS 账号
为了完成此workshop，您需要一个具有管理员访问权限角色的 AWS 账户。 如果您没有，请点击 [此处](https://aws.amazon.com/getting-started/) 创建一个。

**成本**: 如果您的账户不到 12 个月，AWS 免费套餐将包含此workshop中所需的部分资源。 有关更多详细信息，请参阅 [AWS 免费套餐页面](https://aws.amazon.com/free/) 。 为避免在完成研讨会后对您可能不需要的端点和其他资源收费，请参阅**清理模块**。

## AWS 地区
一旦你选择了一个地区，你应该在该地区创建此workshop的所有资源。 我们建议您选择 **Tokyo** 地区。 使用区域下拉列表选择 **Asia Pacific (Tokyo)ap-northeast-1**。 

## 浏览器
我们建议您使用最新版本的 **Chrome** 来完成本次研讨会。 

## AWS 命令行界面
要完成此workshop的某些模块，您需要 AWS 命令行界面 (CLI) 和 Bash 环境。 您将使用 AWS CLI 与 AWS 服务交互。

对于此workshop，AWS Cloud9 用于避免在您的机器上配置 CLI 可能出现的问题。 AWS Cloud9 是一个基于云的集成开发环境 (IDE)，让您只需一个浏览器即可编写、运行和调试代码。 它预先安装了 AWS CLI，因此您无需安装文件或配置您的笔记本电脑即可使用 AWS CLI。 有关此workshop的 Cloud9 设置说明，请参阅 **设置 Cloud9**。 请勿在现场workshop演示期间尝试使用本地安装的 AWS CLI，因为现场演示期间没有足够的时间来解决相关问题。

## SageMaker 资源要求

为了测试此workshop的某些功能，您的 SageMaker 资源限制需要满足以下最低要求。 单击 [此处](https://sagemaker-tools.corp.amazon.com/limits) 检查并增加 SageMaker 资源限制 

|Region |Resource type |Resource | 	Required limit |
|--- |--- | --- | --- |
|ap-northeast-1|SageMaker Training |training-job/ml.p2.xlarge |2|
|ap-northeast-1|SageMaker Processing |processing-job/ml.m5.large |2|
