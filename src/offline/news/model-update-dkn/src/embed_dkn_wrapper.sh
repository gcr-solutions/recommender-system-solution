#!/usr/bin/env bash

echo pwd: $(pwd)
echo ""
echo "Start running ==== python embed_dkn.py ===="

python embed_dkn.py \
--learning_rate 0.0001 \
--loss_weight 1.0 \
--max_click_history 16 \
--num_epochs 1 \
--use_entity True \
--use_context 0 \
--max_title_length 16 \
--entity_dim 128 \
--word_dim 300 \
--batch_size 128 \
--perform_shuffle 1 \
--data_dir ./model-update-dkn \
--checkpointPath ./model-update-dkn/temp/  \
--servable_model_dir ./model-update-dkn/model_complete/

if [[ $? -ne 0 ]]; then
  echo "error!!!"
  exit 1
fi

# ./model-update-dkn/model_complete/temp-1618990972/saved_model.pb
model_file=$(ls ./model-update-dkn/model_complete/*/saved_model.pb)
mkdir -p ./model-update-dkn/model_latest
mv $model_file ./model-update-dkn/model_latest
cd ./model-update-dkn/model_latest
tar -cvf model.tar saved_model.pb
if [[ $? -ne 0 ]]; then
  echo "error!!!"
  exit 1
fi
gzip model.tar
echo "Done ==== python embed_dkn.py ===="
