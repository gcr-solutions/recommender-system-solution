#!/usr/bin/env bash

echo "################"
echo "run $0 ..."
pwd

if [[ -z $REGION ]];then
   export REGION='ap-northeast-1'
fi

echo "REGION: $REGION"

./step_funcs/clean_up.sh
./lambda/clean_up.sh
