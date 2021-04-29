#!/usr/bin/env bash

echo "run $0 ..."
pwd

if [[ -z $REGION ]];then
    REGION='ap-southeast-1'
fi

echo "REGION: $REGION"

./step_funcs/clean_up.sh
./lambda/clean_up.sh
