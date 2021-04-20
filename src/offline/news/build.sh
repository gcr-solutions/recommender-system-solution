
export PROFILE='rsops'
export REGION='ap-southeast-1'

steps=(
action-preprocessing
dashboard
inverted-list
model-update-graph
recall-batch
add-item-user-batch
item-feature-update-batch
portrait-batch
filter-batch
item-preprocsssing
rank-batch
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
# ./build.sh

