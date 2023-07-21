#!/bin/bash
set -x
GENIUSER=`geni-get user_urn | awk -F+ '{print $4}'`
if [ $? -ne 0 ]; then
echo "ERROR: could not run geni-get user_urn!"
exit 1
fi

python3 /mydata/$GENIUSER/cornflakes/experiments/cf-kv-bench.py -e loop \
    -f /mydata/$GENIUSER/expdata/threshold_heatmap \
    -c /mydata/$GENIUSER/config/cluster_config.yaml \
    -ec /mydata/$GENIUSER/cornflakes/cf-kv/ycsb.yaml \
    -lt /mydata/$GENIUSER/data/ycsb/workloadc-1mil/workloadc-1mil-1-batched.load \
    -qt /mydata/$GENIUSER/data/ycsb/workloadc-1mil/workloadc-1mil-1-batched.access \
    -lc /mydata/$GENIUSER/cornflakes-scripts/yamls/fig5partial.yaml
