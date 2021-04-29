#!/usr/bin/env bash

echo "################"
build_dir=$(pwd)

echo "build_dir: ${build_dir}"

AWS_ACCOUNT_ID=$(aws  sts get-caller-identity  --o text | awk '{print $1}')

if [[ $? -ne 0 ]]; then
  echo "error!!! can not get your AWS_ACCOUNT_ID"
  exit 1
fi

if [[ -z $REGION ]];then
    export REGION='ap-northeast-1'
fi

echo "AWS_ACCOUNT_ID: ${AWS_ACCOUNT_ID}"
echo "REGION: ${REGION}"

cd ${build_dir}/lambda
echo "1. >> Deploy lambda ..."
./build.sh
if [[ $? -ne 0 ]]; then
      echo "error!!! Deploy lambda"
      exit 1
fi

cd ${build_dir}/step_funcs
echo "2. >> Deploy step funcs ..."
./build.sh
if [[ $? -ne 0 ]]; then
      echo "error!!! Deploy step funcs"
      exit 1
fi
echo "Offline deploy successfully"

