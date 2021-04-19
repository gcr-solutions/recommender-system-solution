

aws s3 --profile rsops cp item.csv s3://aws-gcr-rs-sol-workshop-ap-southeast-1-522244679887/sample-data/system/item-data/ --acl bucket-owner-full-control
aws s3 --profile rsops cp user.csv s3://aws-gcr-rs-sol-workshop-ap-southeast-1-522244679887/sample-data/system/user-data/ --acl bucket-owner-full-control
aws s3 --profile rsops cp action.csv s3://aws-gcr-rs-sol-workshop-ap-southeast-1-522244679887/sample-data/system/action-data/ --acl bucket-owner-full-control

for file in $(ls action*csv);
do
   aws s3 --profile rsops cp $file s3://aws-gcr-rs-sol-workshop-ap-southeast-1-522244679887/sample-data/system/ingest-data/action/ --acl bucket-owner-full-control
done

for file in $(ls item_*.csv);
do
  aws s3 --profile rsops cp $file s3://aws-gcr-rs-sol-workshop-ap-southeast-1-522244679887/sample-data/system/ingest-data/item/ --acl bucket-owner-full-control
done


for file in $(ls user.csv);
do
  aws s3 --profile rsops cp $file s3://aws-gcr-rs-sol-workshop-ap-southeast-1-522244679887/sample-data/system/ingest-data/user/ --acl bucket-owner-full-control
done



cd /Users/yonmzn/work/rs_demo/data/data_files

data_files=(
entity_industry.txt
vocab.json
entities_dbpedia.dict
kg_dbpedia.txt
relations_dbpedia.dict
)

for file in ${data_files[@]};
do
 aws s3 --profile rsops cp $file  s3://aws-gcr-rs-sol-workshop-ap-southeast-1-522244679887/sample-data/model/meta_files/
done
