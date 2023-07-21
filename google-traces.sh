#!/bin/bash
set -x
GENIUSER=`geni-get user_urn | awk -F+ '{print $4}'`
if [ $? -ne 0 ]; then
echo "ERROR: could not run geni-get user_urn!"
exit 1
fi

python3 /mydata/$GENIUSER/cornflakes/experiments/google-bench.py \
    -e loop \
    -f /mydata/$GENIUSER/expdata/googleproto_cfkv  \
    -c /mydata/$GENIUSER/config/cluster_config.yaml \
    -ec /mydata/$GENIUSER/cornflakes/cf-kv/google.yaml \
    -lc /mydata/$GENIUSER/cornflakes-scripts/yamls/fig6.yaml
