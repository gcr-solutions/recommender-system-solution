#!/usr/bin/env bash

echo "################"
echo "run $0 ..."
pwd

scripts_dir=$(pwd)

cd ../sample-data/
./sync_data_to_s3.sh

echo "----------------------"
cd ${scripts_dir}/../src/offline
./build.sh


# Need below Role to create the stack
#
#IAMFullAccess
#AmazonS3FullAccess
#AmazonSNSFullAccess
#AWSStepFunctionsFullAccess
#AmazonSageMakerFullAccess
#CloudWatchEventsFullAccess
#AWSCloudFormationFullAccess
#AWSLambda_FullAccess
#