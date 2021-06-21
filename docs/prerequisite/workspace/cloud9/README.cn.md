---
title: 设置 Cloud9
weight: 1
---

AWS Cloud9 是一个基于云的集成开发环境 (IDE)，让您只需一个浏览器即可编写、运行和调试代码。 它包括代码编辑器、调试器和终端。

## 创建新的Cloud9 IDE 环境

1. 打开 [AWS Cloud9 Console](https://ap-northeast-1.console.aws.amazon.com/cloud9)
2. 点击地区选择列表并选择 **Asia Pacific (Tokyo)ap-northeast-1**
3. 点击 **Create environment** 按钮来创建新的Cloud9环境

![Create Cloud9 Environment](/images/create-cloud9-start.png)

4. 命名为 `gcr-rs-workshop`, 点击 **下一步**
5. 保留所有默认选项, 点击 **下一步** 与 **创建环境**

{{% notice info %}}
这将需要大约 2 分钟的时间进行配置
{{% /notice %}}

当配置完成时，cloud9 控制台环境应该如下所示： 

![Cloud9 Welcome](/images/cloud9-welcome.png)

## 配置 Cloud9 IDE 环境 

当环境创建成功后，通过以下方式配置环境： 

1 . 关闭所有窗口

![Cloud9 Close](/images/cloud9-close.png)

2 . 打开一个新的命令行窗口

![Cloud9 Open Terminal](/images/cloud9-open-terminal.png)

3 . 在整个workshop部署期间，在浏览器中保持AWS Cloud9的打开状态，因为我们将通过它进行诸如使用 AWS CLI 和运行 Bash 脚本之类的工作。 

