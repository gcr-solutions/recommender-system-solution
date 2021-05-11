
# get endpoint
elb_names=($(aws elb describe-load-balancers --output text | grep LOADBALANCERDESCRIPTIONS |  awk '{print $6 }'))

echo "find $#elb_names elbs"

system_elb=''
for elb in ${elb_names[@]};
do
  echo "check elb $elb ..."
  aws elb describe-tags --load-balancer-name $elb --output text  | grep 'istio-system/istio-ingressgateway'
  if [[ $? -eq '0' ]];then
     echo "find system-endpoint $elb"
     system_elb=$elb
     break
  fi
done

dns_name=$(aws elb describe-load-balancers --load-balancer-name $system_elb --output text | grep LOADBALANCERDESCRIPTIONS | awk '{print $2 }')

echo "endpoint: $dns_name"

#inverted-list
curl -X POST -d '{"message": {"file_type": "inverted-list", "file_path": "sample-data/notification/inverted-list/","file_name": ["embed_raw_item_mapping.pickle","embed_raw_user_mapping.pickle","filter_batch_result.pickle","news_entities_news_ids_dict.pickle","news_id_news_feature_dict.pickle","news_id_news_property_dict.pickle","news_keywords_news_ids_dict.pickle","news_type_news_ids_dict.pickle","news_words_news_ids_dict.pickle","portrait.pickle","rank_batch_result.pickle","raw_embed_item_mapping.pickle","raw_embed_user_mapping.pickle","recall_batch_result.pickle"]}}' -H "Content-Type:application/json" http://$dns_name/loader/notice

sleep 20

# action-model
curl -X POST -d '{"message": {"file_type": "action-model","file_path": "sample-data/notification/action-model/","file_name": ["model.tar.gz"]}}' -H "Content-Type:application/json" http://$dns_name/loader/notice

sleep 20

# embedding
curl -X POST -d '{"message": {"file_type": "embedding","file_path": "sample-data/notification/embeddings/","file_name": ["dkn_context_embedding.npy","dkn_entity_embedding.npy","dkn_relation_embedding.npy","dkn_word_embedding.npy"]}}' -H "Content-Type:application/json" http://$dns_name/loader/notice

sleep 20
# item record data
curl -X POST -d '{"message": {"file_type": "news_records","file_path": "sample-data/system/item-data/","file_name": ["item.csv"]}}' -H "Content-Type:application/json" http://$dns_name/api/v1/demo/notice

echo 'Complete'