---
title: Install kubectl 
weight: 3
---

kubectl is a command line tool for working with Kubernetes clusters.
1. install kubectl using the following command:

    sudo curl --silent --location -o /usr/local/bin/kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/kubectl

    sudo chmod +x /usr/local/bin/kubectl

2. Confirm the kubectl command works:
    kubectl version


