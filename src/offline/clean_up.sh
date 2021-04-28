#!/usr/bin/env bash

echo "run $0 ..."
pwd

if [[ -z $PROFILE ]];then
   PROFILE='default'
fi

if [[ -z $REGION ]];then
    REGION='ap-southeast-1'
fi

echo "PROFILE: $PROFILE"
echo "REGION: $REGION"

./step_funcs/clean_up.sh
./lambda/clean_up.sh
