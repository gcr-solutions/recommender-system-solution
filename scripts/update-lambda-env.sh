#!/usr/bin/env bash

echo "################"

if [[ -z $AWS_REGION ]];then
    REGION=$AWS_REGION
fi

if [[ -z $REGION ]];then
    REGION='ap-northeast-1'
fi

account_id=$(aws sts get-caller-identity --query Account --output text)

if [[ $? -ne 0 ]]; then
  echo "error!!! can not get your AWS_ACCOUNT_ID"
  exit 1
fi

echo "REGION: $REGION"
echo "ACCOUNT_ID: $account_id"

elb_names=($(aws elb  describe-load-balancers --output text | grep LOADBALANCERDESCRIPTIONS |  awk '{print $6 }'))

echo "find $#elb_names elbs"

ingressgateway_elb=''
for elb in ${elb_names[@]};
do
  echo "check elb $elb ..."
  aws elb describe-tags  --load-balancer-name $elb --output text  | grep 'istio-ingressgateway'
  if [[ $? -eq '0' ]];then
     echo "find ingressgateway $elb"
     ingressgateway_elb=$elb
     break
  fi
done

echo "ingressgateway_elb: $ingressgateway_elb"

if [[ -z $ingressgateway_elb ]];then
  echo "Error: cannot find istio ingress gateway"
  exit 1
fi

dns_name=$(aws elb  describe-load-balancers --load-balancer-name $ingressgateway_elb --output text | grep LOADBALANCERDESCRIPTIONS | awk '{print $2 }')

echo "dns_name: $dns_name"

loader_url="http://$dns_name/loader/notice"
echo $loader_url

botoConfig='{"user_agent_extra": "AwsSolution/SO8010/0.1.0"}'
SNS_TOPIC_ARN="arn:aws:sns:${REGION}:${account_id}:rsdemo-offline-sns"
echo $SNS_TOPIC_ARN

aws lambda   update-function-configuration  --function-name rsdemo-SNSMessageLambda \
--environment "Variables={ONLINE_LOADER_URL=${loader_url},botoConfig='${botoConfig}',SNS_TOPIC_ARN='${SNS_TOPIC_ARN}'}" >/dev/null


