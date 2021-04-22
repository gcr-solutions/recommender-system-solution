
export PROFILE='rsops'
export REGION='ap-southeast-1'

steps=(
action-preprocessing
inverted-list
item-preprocsssing
model-update-embedding
rank-batch
step_funcs
add-item-user-batch
dashboard
filter-batch
item-feature-update-batch
model-update-action
portrait-batch
recall-batch
weight-update-batch
)
build_dir=$(pwd)
for t in ${steps[@]};
do
   cd ${build_dir}/${t}
   echo ">> Build ${t} ..."
    ./build.sh
done

cd ${build_dir}/../lambda
echo ">> Build lambda ..."
./build.sh

cd ${build_dir}/step_funcs
echo ">> Build step_funcs ..."
 ./build.sh

