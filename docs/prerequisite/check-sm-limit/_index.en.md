---
title: Check Sagemaker resources limit
weight: 10
---

Check Sagemaker resources limit in your AWS account

1. Go to link `https://sagemaker-tools.corp.amazon.com/limits`


![Sagemaker limit request](/images/sm-limit-req.png)


2. Check Sagemaker training job resources limit

Check limit for `training-job/ml.p2.xlarge`, it should be at least 1, better request for 3. 

![Sagemaker training job limit](/images/sm-limit-training.png)

![Sagemaker training job limit for p2.xlarge](/images/sm-limit-training-p2.png)


3. Check Sagemaker processing job resources limit

Check limit for `processing-job/ml.m5.xlarge`, it should be at least 1, better request for 3. 

![Sagemaker processing job limit](/images/sm-limit-processing.png)

![Sagemaker processing job limit for m5.xlarge](/images/sm-limit-processing-m5-xlarge.png)
