#!/bin/bash
set -x
GENIUSER=`geni-get user_urn | awk -F+ '{print $4}'`
if [ $? -ne 0 ]; then
echo "ERROR: could not run geni-get user_urn!"
exit 1
fi

python3 /mydata/$GENIUSER/cornflakes/experiments/twitter-bench.py -e loop \
    -f /mydata/$GENIUSER/expdata/twitter_redis \
    -c /mydata/$GENIUSER/config/cluster_config.yaml \
    -ec /mydata/$GENIUSER/cornflakes/experiments/yamls/cmdlines/redis-twitter.yaml \
    -lc /mydata/$GENIUSER/cornflakes/experiments/yamls/loopingparams/twitter_traces/cf-kv-twitter-redis.yaml \
    --trace /mydata/$GENIUSER/data/twitter/cluster4.0_subset
