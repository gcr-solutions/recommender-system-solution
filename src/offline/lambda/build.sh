#!/usr/bin/env bash

./package_code_to_s3.sh
./deploy_lambda.sh
./update_lambda_code.sh
