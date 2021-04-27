elb_names=($(aws elb describe-load-balancers --output text | grep LOADBALANCERDESCRIPTIONS |  awk '{print $6 }'))

echo "find $#elb_names elbs"

argocdserver_elb=''
for elb in ${elb_names[@]};
do
  echo "check elb $elb ..."
  aws elb describe-tags --load-balancer-name $elb --output text  | grep 'argocd-server'
  if [[ $? -eq '0' ]];then
     echo "find argocd-server $elb"
     argocdserver_elb=$elb
     break
  fi
done

dns_name=$(aws elb describe-load-balancers --load-balancer-name $argocdserver_elb --output text | grep LOADBALANCERDESCRIPTIONS | awk '{print $2 }')

echo "dns_name: $dns_name"