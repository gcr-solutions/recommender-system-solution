---
title: Check SageMaker resources limit
weight: 20
---

Check SageMaker resources limit in your AWS account

1. Go to link `https://sagemaker-tools.corp.amazon.com/limits`
   fill your AWS account id and select region `ap-northeast-1`
   
   ![Sagemaker limit request](/images/sm-limit-req.png)


2. Check **SageMaker Training** resources limit

   select **RESOURCE TYPE:** `SageMaker Training`, check limit for `training-job/ml.p2.xlarge`, it should be at least 1, better request for 3. 

   ![Sagemaker training job limit](/images/sm-limit-training.png)

   ![Sagemaker training job limit for p2.xlarge](/images/sm-limit-training-p2.png)


3. Check **SageMaker Processing** resources limit

   select **RESOURCE TYPE:** `SageMaker Processing`, check limit for `processing-job/ml.m5.xlarge`, it should be at least 1, better request for 3. 

   ![Sagemaker processing job limit](/images/sm-limit-processing.png)

   ![Sagemaker processing job limit for m5.xlarge](/images/sm-limit-processing-m5-xlarge.png)
