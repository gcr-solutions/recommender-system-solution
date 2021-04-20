# Event offline design
1. 每日落盘后的batch process
    1. action-preprocessing: 清理用户数据
        1. 输入：
            1. s3上的用户数据
        2. 输出：
            1. action.csv
    2. inverted-list: 生成倒排索引（包含热度分析）
        1. 输入：
            1. item.csv
            2. action.csv(热度逻辑/分析)
        2. 输出：
            1. news_id_news_property_dict.pickle
            2. news_type_news_ids_dict.pickle
            3. news_keywords_news_ids_dict.pickle
            4. news_entities_news_ids_dict.pickle
            5. news_words_news_ids_dict.pickle
    3. portrai-batch: 用户画像更新
        1. 输入：
            1. action.csv
            2. raw_embed_user_mapping.pickle
            3. raw_embed_item_mapping.pickle
            4. portrait.pickle （if new user added, it will update）
            5. news_id_news_property_dict.pickle
        2. 输出
            1. portrait.pickle
    4. weight-update-batch: 更新不同策略的权重信息
        1. 输入：
            1. action.csv
            2. recall_config.pickle
        2. 输出:
            1. recall_config.pickle
    5. recall-batch
        1. 输入：
            1. action.csv 
            2. portrait.pickle
            3. recall_config.pickle
            4. news_id_news_property_dict.pickle
            5. news_type_news_ids_dict.pickle
            6. news_keywords_news_ids_dict.pickle
            7. news_words_news_ids_dict.pickle
            8. news_entities_news_ids_dict.pickle
        2. 输出：
            1. recall_batch_result.pickle
    6. rank-batch
        1. 输入：
            1. recall_batch_result.pickle
            2. news_id_news_feature_dict.pickle
            3. portrait.pickle
            4. model.tar.gz
        2. 输出
            1. rank_batch_result.pickle
    7. filter-batch
        1. 输入：
            1. recall_batch_result.pickle
            2. rank_batch_result.pickle
        2. 输出
            1. filter_batch_result.pickle

2. 新物品上线的batch process：加入feature
    1. inverted-list: 生成倒排索引（包含热度分析/新的物品优先级往前）
        1. 输入：
            1. item.csv (增加一个字段标记为新物品)
        2. 输出：
            1. news_id_news_property_dict.pickle
            2. news_type_news_ids_dict.pickle
            4. news_words_news_ids_dict.pickle
            5. news_entities_news_ids_dict.pickle
            6. news_keywords_news_ids_dict.pickle
    2. add-item-user-batch: 加入新的用户/物品逻辑
        1. 输入：
            1. item.csv
            2. user.csv
        2. 输出：
            1. raw_embed_user_mapping.pickle
            2. raw_embed_item_mapping.pickle
            3. embed_raw_user_mapping.pickle
            4. embed_raw_item_mapping.pickle
    3. item-feature-update-batch: 物品feature更新(1.check current kg；2.update feature)
        1. 输入：
            1. item.csv
            2. complete_dkn_word_embedding.npy
        2. 输出：
            1. news_id_news_feature_dict.pickle
            2. dkn_word_embedding.npy
            3. kg_check_list.pickle
    4. model-update-graph: 1. 清理出训练数据；2.训练行为模型
        1. 输入：
            1. action.csv
            2. news_id_news_feature_dict.pickle
        2. 输出：
            1. dkn_entity_embedding.npy
            2. dkn_context_embedding.npy
    5. model-update-dkn: 1. 清理出训练数据；2.训练行为模型
        1. 输入：
            1. action.csv
            2. news_id_news_feature_dict.pickle
            3. user_portrait.pickle
        2. 输出：
            1. model.tar.gz

3. 行为数据更新的model update：
    1. action-preprocessing: 清理用户数据
        1. 输入：
            1. s3上的用户数据
        2. 输出：
            1. action.csv
    2. model-update-dkn: 1. 清理出训练数据；2.训练行为模型
        1. 输入：
            1. action.csv
            2. news_id_news_feature_dict.pickle
            3. dkn_entity_embedding.npy
            4. dkn_word_embedding.npy
            5. dkn_context_embedding.npy
        2. 输出：
            1. model.tar.gz

## S3 目录结构


bucket: xxxx

    |-- xxxx
        |-- feature
            |-- action 
                |-- embed_raw_item_mapping.pickle
                |-- embed_raw_user_mapping.pickle
                |-- raw_embed_item_mapping.pickle
                |-- raw_embed_user_mapping.pickle
                |-- ub_item_embeddings.npy
                |-- ub_item_vector.index
            |-- content
                |-- vector
                    |-- review.index
                    |-- image.index
                |-- inverted-list
                    |-- news_id_news_property_dict.pickle
                    |-- news_category_news_ids_dict.pickle
                    |-- news_director_news_ids_dict.pickle
                    |-- news_actor_news_ids_dict.pickle
                    |-- news_language_news_ids_dict.pickle
                    |-- news_level_news_ids_dict.pickle
                    |-- news_year_news_ids_dict.pickle
            |-- recommend-list
                |-- news
                    |-- recall_batch_result.pickle
                    |-- rank_batch_result.pickle
                    |-- filter_batch_result.pickle
                |-- tv
                |-- portrait
                    |-- portrait.pickle
        |-- model
            |-- recall
                |-- recall_config.pickle
                |-- youtubednn
                    |-- ub_user_embedding.h5 
                |-- review
                |-- image-similariy
            |-- rank
                |-- action
                    |-- deepfm
                        |-- latest
                            |-- model.tar.gz
                    |-- xgboost
                |-- content
            |-- filter
                |-- filter_config.pickle
        |-- system
            |-- user-data
                |-- clean
                    |-- latest
                        |-- action.csv
                |-- action
                    |-- yyyy-mm-dd
                        |-- exposure
                        |-- play
                |-- portrait
                    |-- ProfileMap.csv
            |-- item-data
                |-- photo
                    |-- xxx.jpg
                |-- basic
                    |-- 1.csv
                |-- expand
                    |-- 1.xlsx

## 如何Setup offline

### 1. 创建CodeBuild

```sh

export PROFILE=<your_aws_profile>

cd recommender-system/hack/codebuild
# 创建 iam role for codebuild
./create-iam-role.sh

# 如果使用 github， 需要运行下面脚本，创建访问github repo的 SSM
./create-secrets.sh

# 如果使用 AWS CodeCommit， 需要做以下工作：
#
# 1. 创建一个 CodeCommit repo
#
# 2. checkin code 到你自己的 CodeCommit
#
# 3. 将 codebuild-template-offline-codecommit.json 中的内容，copy 到 codebuild-template-offline.json 中，覆盖原来的内容
#    修改 "location": "https://git-codecommit.ap-northeast-1.amazonaws.com/v1/repos/mk-test" 指向你自己的 repo
#
# 4. 修改 src/offline/**/buildspec.yaml 删除 secrets-manager
#
 
# 创建 code build
./register-to-codebuild-offline.sh
```

### 2. 配置数据 Bucket 以及第一层目录

```cd recommender-system/src/offline```

编辑如下两个文件  
``` 
lambda/config.json
step-funcs/config.json
```
   
### 3. build offline 模块
```sh
cd recommender-system/src/offline
./build_offline_all.sh
```
打开 AWS Codebuild 的console, 确保都运行成功。
在 region `ap-southeast-1` Codebuild 的 console 链接如下：
https://ap-southeast-1.console.aws.amazon.com/codesuite/codebuild/start?region=ap-southeast-1

### 4. Prepare data 
- Action 数据存放位置
``` 
s3://gcr-rs-ops-ap-southeast-1-522244679887/recommender-system-film-mk/1/system/user-data/action/2020-12-17/exposure/exposurelog.2020-12-17-17.0.csv
s3://gcr-rs-ops-ap-southeast-1-522244679887/recommender-system-film-mk/1/system/user-data/action/2020-12-17/play/playlog.2020-12-17-17.0.csv

```
- Item 数据存放位置
```
s3://gcr-rs-ops-ap-southeast-1-522244679887/recommender-system-film-mk/1/system/item-data/basic/1.csv
s3://gcr-rs-ops-ap-southeast-1-522244679887/recommender-system-film-mk/1/system/item-data/expand/1.xlsx
```

__注意__： Bucket `gcr-rs-ops-ap-southeast-1-522244679887` 和第一层folder `recommender-system-film-mk` 可以在下面两个文件配置：
```
src/offline/lambda/config.json
src/offline/step-funcs/config.json
```


### 5. 查看和运行StepFunc

打开 AWS statemachines 的console, 在 region `ap-southeast-1` 链接如下：

https://ap-southeast-1.console.aws.amazon.com/states/home?region=ap-southeast-1#/statemachines

点击 StepFunc "RS-OverallStepFunc" -> "Start execution"
输入如下Input：
```json
{
  "regionId": "1",
  "change_type": "ACTION"
}
```