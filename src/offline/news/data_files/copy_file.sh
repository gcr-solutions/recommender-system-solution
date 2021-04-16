

aws s3 --profile rsops cp item.csv s3://aws-gcr-rs-sol-workshop-ap-southeast-1-522244679887/sample-data/system/item-data/ --acl bucket-owner-full-control
aws s3 --profile rsops cp user.csv s3://aws-gcr-rs-sol-workshop-ap-southeast-1-522244679887/sample-data/system/user-data/ --acl bucket-owner-full-control
aws s3 --profile rsops cp action.csv s3://aws-gcr-rs-sol-workshop-ap-southeast-1-522244679887/sample-data/system/action-data/ --acl bucket-owner-full-control

for file in $(ls action*csv);
do
   aws s3 --profile rsops cp $file s3://aws-gcr-rs-sol-workshop-ap-southeast-1-522244679887/sample-data/system/ingest-data/action/ --acl bucket-owner-full-control
done