#!/usr/bin/env bash

echo "################"
Red=$'\e[1;31m'
Green=$'\e[1;32m'
Yellow=$'\e[1;33m'
Blue=$'\e[1;34m'

OK_print () {
   echo -e "$Green $1 \e[39m"
}
Error_print() {
	 echo -e "$Red $1 \e[39m"
}

Yellow_print() {
  echo -e "$Yellow $1 \e[39m"
}

Blue_print() {
  echo -e "$Blue $1 \e[39m"
}



build_dir=$(pwd)

echo "build_dir: ${build_dir}"

AWS_ACCOUNT_ID=$(aws  sts get-caller-identity  --o text | awk '{print $1}')

if [[ $? -ne 0 ]]; then
  Error_print "error!!! can not get your AWS_ACCOUNT_ID"
  exit 1
fi

if [[ -z $REGION ]];then
    export REGION='ap-northeast-1'
fi

Yellow_print "AWS_ACCOUNT_ID: ${AWS_ACCOUNT_ID}"
Yellow_print "REGION: ${REGION}"

cd ${build_dir}/lambda
Blue_print "1. >> Deploy lambda ..."
./build.sh
if [[ $? -ne 0 ]]; then
      Error_print "error!!! Deploy lambda"
      exit 1
fi

cd ${build_dir}/step_funcs
Blue_print "2. >> Deploy step funcs ..."
./build.sh
if [[ $? -ne 0 ]]; then
      Error_print "error!!! Deploy step funcs"
      exit 1
fi
OK_print "Offline deploy successfully"

