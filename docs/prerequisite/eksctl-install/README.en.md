---
title: Install eksctl 
weight: 2
---

eksctl is a command line tool for working with EKS clusters that automates many individual tasks.
1. install [eksctl](https://eksctl.io/) using the following command:

    curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp

    sudo mv -v /tmp/eksctl /usr/local/bin


2. Confirm the eksctl command works:
    eksctl version


