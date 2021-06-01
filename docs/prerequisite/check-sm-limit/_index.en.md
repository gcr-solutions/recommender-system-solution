---
title: Check Sagemaker resources limit in your AWS account
weight: 10
---

1. Go to link [`https://sagemaker-tools.corp.amazon.com/limits`](https://sagemaker-tools.corp.amazon.com/limits)

![Sagemaker limit request](/images/sm-limit-req.png)

2. Check Sagemaker training job resources limit

![Sagemaker training job limit](/images/sm-limit-training.png)

Check limit for `training-job/ml.p2.xlarge`, it should be at least 1 limit, better request for 3. 

![Sagemaker training job limit for p2.xlarge](/images/sm-limit-training-p2.png)

3. Check Sagemaker processing job resources limit

![Sagemaker processing job limit](/images/sm-limit-processing.png)

Check limit for `processing-job/ml.m5.xlarge`, it should be at least 1 limit, better request for 3. 

![Sagemaker processing job limit for m5.xlarge](/images/sm-limit-processing-m5-xlarge.png)