
PROFILE=rsops

dist_prefix=s3://sagemaker-ap-southeast-1-522244679887/rsdemo

aws --profile $PROFILE s3 cp ./raw_action_data/58444b16f51e474f-5304ff7a00000004_60074785_data.0.csv  $dist_prefix/system/user-data/raw_action_data/
aws --profile $PROFILE s3 cp  ./data_files/kg_dbpedia.txt           $dist_prefix/model/sort/content/words/mapping/kg_dbpedia.txt
aws --profile $PROFILE s3 cp  ./data_files/entity_industry.txt      $dist_prefix/model/sort/content/words/mapping/entity_industry.txt
aws --profile $PROFILE s3 cp  ./data_files/dkn_word_embedding.npy   $dist_prefix/model/sort/content/words/sgns-mixed-large/dkn_word_embedding.npy
aws --profile $PROFILE s3 cp  ./data_files/relations_dbpedia.dict   $dist_prefix/model/sort/content/words/mapping/relations_dbpedia.dict
aws --profile $PROFILE s3 cp  ./data_files/news_map.csv             $dist_prefix/model/news_map.csv/
aws --profile $PROFILE s3 cp  ./data_files/entities_dbpedia.dict    $dist_prefix/model/sort/content/words/mapping/entities_dbpedia.dict
aws --profile $PROFILE s3 cp  ./data_files/toutiao_cat_data.txt     $dist_prefix/system/item-data/raw-input/toutiao_cat_data.txt
aws --profile $PROFILE s3 cp  ./data_files/vocab.json               $dist_prefix/model/sort/content/words/mapping/vocab.json
aws --profile $PROFILE s3 cp  ./data_files/user_map.csv             $dist_prefix/model/user_map.csv/


