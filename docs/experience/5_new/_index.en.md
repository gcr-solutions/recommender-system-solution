---
title: New Items Added And Batch Update
weight: 45
---

The recommender system does not only have new action data collected. In real scenario, new items, e.g. news, movies, music..., will be added to the system and should be integrated in the whole system. We have prepared the following two logic for this requirement:

![item-batch-offline](/images/item-batch-offline.png)

We have prepared some news to be added for you:

![news-to-add](/images/news-to-add.png)


Add new items to recommender system
```shell
cd /home/ec2-user/environment/recommender-system-solution/sample-data

./new_item_to_s3.sh

```

You should never see them before you run these two functions. First, you should run the offline logic for new content:

![item-offline](/images/item-offline.png)

The logic behind this function is shown below:

![content-logic-image](/images/content-logic-image.png)

You can tell that the whole news are analyzed at first and then relating models are updated. After that, you should click the icon for batch process:

![batch-offline](/images/batch-offline.png)

When all these functions are finished, you should likely see these added news recommended for you in the system:

![new-recommend](/images/new-recommend.png)

In regular maintenance, you can trigger batch process offline function to generate the recommendation list for each user. These results will be loaded in the redis and can be fetched on line.








