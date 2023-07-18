#!/bin/bash
set -x
GENIUSER=`geni-get user_urn | awk -F+ '{print $4}'`
if [ $? -ne 0 ]; then
echo "ERROR: could not run geni-get user_urn!"
exit 1
fi

python3 twitter-bench.py -e loop -f /mydata/$GENIUSER/expdata/twitter_cfkv -c /mydata/$GENIUSER/config/cluster_config.yaml -ec mydata/$GENIUSER/cornflakes/cf-kv/twitter.yaml -lc /mydata/$GENIUSER/cornflakes/experiments/yamls/loopingparams/twitter_traces/cf-kv-twitter.yaml --trace /nfs/experimentdata/$GENIUSER/twitter/cluster4.0_subset
