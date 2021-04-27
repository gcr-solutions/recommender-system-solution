elb_names=($(aws elb describe-load-balancers --output text | grep LOADBALANCERDESCRIPTIONS |  awk '{print $6 }'))

echo "find $#elb_names elbs"

ingressgateway_elb=''
for elb in ${elb_names[@]};
do
  echo "check elb $elb ..."
  aws elb describe-tags --load-balancer-name $elb --output text  | grep 'istio-ingressgateway'
  if [[ $? -eq '0' ]];then
     echo "find istio-ingressgateway $elb"
     ingressgateway_elb=$elb
     break
  fi
done

dns_name=$(aws elb describe-load-balancers --load-balancer-name $ingressgateway_elb --output text | grep LOADBALANCERDESCRIPTIONS | awk '{print $2 }')

echo "dns_name: $dns_name"