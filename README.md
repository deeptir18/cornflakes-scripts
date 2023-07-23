# cornflakes-scripts
This repository contains scripts to run and reproduce results from the SOSP paper,
Cornflakes: Zero-Copy Serialization for Microsecond-Scale Networking,
conditionally accepted at SOSP 2023, on Cloudlab.
The scripts in this repository assume you have setup machines
via the custom cloudlab-profile linked below; this profile 
sets up Cloudlab machines with all the necessary dependencies.
The scripts in this repo assume certain filepaths (i.e., cornflakes is located at
/mydata/$USER/cornflakes) which the cloudlab profile sets up automatically; if
you manually clone cornflakes into a different path, you must change the paths
in these scripts.
The traces used in the evaluation are located in a Cloudlab
long-term dataset; the cloudlab profile mounts the traces one machine and the
setup scripts scp the traces to all machines on startup.
The main Cornflakes repo contains
instructions for how to get started with Cornflakes on your own hardware; this
repo is intended for reproducing the main results.

# Code version and structure
This repository assumes [cornflakes](https://github.com/deeptir18/cornflakes), on the main branch, at XXXX commit hash,
and the cloudlab profile pointing to [this repository](https://github.com/deeptir18/cornflakes-cloudlab-profile) at main and XXXX commit hash.
We briefly describe the code structure of Cornflakes below.
```
cornflakes
    - cf-kv:  source code for kv store application
    - redis: redis submodule with changes to redis
    - cornflakes-codegen: boilerplate for generating Rust serialization code
    - cornflakes-libos: common serialization and datapath interface code
    - cornflakes-utils: common utilities for running binaries
    - mlx5-datapath: custom datapath built on Mellanox OFED drivers.
    - ice-datapath: custom datapath built on Intel Ice drivers.
    - dpdk-datapath: interface to datapath over DPDK (mainly used for client
      load generators).
```

# Cloudlab profile instructions (1 hour machine time, 15-20 minutes human time)
We have provided a [cloudlab profile](https://www.cloudlab.us/p/955539a31b0c7be330933414edd8d4af54f7dbec) that automaticaly installs and configures
most of what is needed to run Cornflakes (there is some configuration that must
be done once the install scripts finish).
## Dataset
The cloudlab dataset is at
`urn:publicid:IDN+utah.cloudlab.us:demeter-pg0+ltdataset+cornflakes-data`; this
is in the Utah cluster; the default argument in the Cloudlab profile points to
this dataset.
## Hardware
To run the evaluation, you MUST use a cluster with either d6515, or c6525-100g, or c6525-25g
nodes in the Cloudlab Utah cluster (the dataset containing the traces is located
on the Utah cluster); we highly recommend c6525-100g.
We tested using c6525-100g machines; if you use
c6525-25g machines you may see different results (lower raw throughputs), because the network bandwidth
is lower.

## Profile
The cloudlab profile is located [here](https://www.cloudlab.us/p/955539a31b0c7be330933414edd8d4af54f7dbec). Please instantiate the profile with the latest `main` default branch. Steps 0-4 should take a couple minutes; Step 5 takes about 1 hour for all the dependencies to install; Step 6 takes another couple minutes to power cycle the machines again.

To use the profile:

0. Press "instantiate".

1. Choose values for parameters: the dataset value already points to the dataset
   described above; choose the machine type; and choose the number of clients.
All results below just require 1 client. Please click the dropdown for
`advanced` and click the checkbox next to `No Interswitch Links` (this ensures
there is only one switch between the client and server machine). A screenshot
using the c6525-100g machines, and 1 client is shown below:
![Alt text](cloudlab_params.png)

2. On the next page, enter a name for the experiment, and select `Cloudlab Utah`
   in the dropdown menu.
![Alt text](cloudlab_topo.png)

3. Press next; the next page indicates if you would like to schedule the
   experiment for later; you can skip and press "Finish" to instantiate
immediately.

4. Wait for 2-3 minutes to ensure the machines are allocated (it helps to have a
   reservation, as c6525-100g machines are more in demand) and the profile has
worked successfully.

5. The install scripts take about 1 hour to run; they install many libraries
   from scratch. **Wait for about 1 hour**.

6. After the cloudlab UI indicates that the startup scripts have _finished_
   running, please reboot (power cycle) each of the machines. This loads the newly installed
Mellanox drivers. Once the cloudlab UI indicates the machines are rebooted, you
are ready to use them for experiments!

7. The results we recommend reproducing take around 5, 14, and 20 hours each to
   run. Therefore, we recommend that you extend the cloudlab experiment for a
few days to finish the artifact evaluation; experiments automatically get
deleted after 16 hours if you're not careful.


## Build cornflakes and configuring the machine post-reboot settings
0. After the cloudlab UI indicates the machines have rebooted, please log into each of the server and client nodes and run the
following (on all nodes). Note that `$USER` refers to your cloudlab username.
```
## clone and build cornflakes
/local/repository/clone_cornflakes.sh
```
After this, on all machines, you will see the following repos at the following
locations:
| Repo | Location |
| --- | ----------- |
| cornflakes | `/mydata/$USER/cornflakes` |
| cornflakes-scripts | `/mydata/$USER/cornflakes-scripts` |
| cornflakes-cloudlab-profile | `/local/repository` |

1. Machine settings. On each machine, log in and run the following:
```
## installs hugetlbfs, required for zero-copy
sudo /mydata/$USER/cornflakes/install/install-hugepages.sh 7500
## disables c-states
sudo /mydata/$USER/cornflakes/install/set_freq.sh
```

2. Configure config file on each machine. To run any cornflakes experiments, Cornflakes requires a config file that
   looks like [sample config](sample_config.md). The following python script
automatically fills in the config file; please do not change the `--outfile`
argument of the python script, where the experiment bash scripts expect the
config file will be located. The following table describes the environment
variables:
| Variables | Definition |
| --- | ----------- |
| `$NUM_CLIENTS` | Number of clients configured in cloudlab profile (e.g., machines named `cornflakes-clientx`) |
| `$MACHINE_NAME` | `cornflakes-server` if the server machine; `cornflakes-clientx` (where x is 1,2,...) for the client machines |

```
python3 /local/repository/generate-config.py --user $USER --num_clients $NUM_CLIENTS --outfile /mydata/$USER/config/cluster_config.py --machine $MACHINE_NAME
```
**Note**: If you are using d6515 machines, please ssh into one of the machines
and check the interface name of the ssh interface (e.g., the interface listed by
`ifconfig` that contains the SSH IP for the machine, which will likely be 128.xxx.xx.xx). `generate-config.py`
hardcodes the variable `SSH_IP_INTERFACE` near the top of the file to the
interface name used by c6525-100g or 25g machines for the SSH interface; for
d6515 machines, please change this.

# Results reproduced overview
## Main results reproduced
We have provided instructions to reproduce Figure 8, Figure 7, Figure 12, and
part of Figure 5.
Figure 8 (Redis integration with the twitter trace) and Figure 7 (comparison to
existing libraries on the twitter trace) show Cornflakes provides gains compared
to existing software serialization approaches. Figure 12 shows that the hybrid approach offers some gain.
The portion of Figure 5 validates our current threshold choice of 512; the full
heatmap takes days to run (but we provide instructions for that as well).

## Optional results 
We have also provided scripts to run the experiments described in Table 2 (CDN
workload), and Figure 6 (the google workload), but we believe the results listed
above constitute the core resuls of the paper.

## How results work
For each figure, we have provided a bash script that invokes the python script
necessary to run the experiment described, which hardcodes locations of
cornflakes and the config files to what the cloudlab profile setup. The form of the bash script is
roughly the following (the trace related arguments depends on the specific
experiment).
```
python3 $PATH_TO_CORNFLAKES/experiments/xx-bench.py -e loop \
    -f $PATH_TO_RESULTS \
    -c $PATH_TO_CLUSTER_CONFIG \
    -ec $PATH_TO_CORNFLAKES/path_to_command_line_yaml \
    -lc $PATH_TO_EXPERIMENT_LOOP \
    --trace <trace_file>
```
Here is information about each parameter. We briefly describe what changing each
would do:
- `$PATH_TO_CLUSTER_CONFIG`: changes the location to the machine's cluster
  config.
- `$PATH_TO_RESULTS`: changes where the expected results for the experiment end
  up.
- `$PATH_TO_CORNFLAKES`: where the cornflakes repo is located.
- `-ec` argument: Each program has a yaml that specifies the command line (for both the server and client) specified by the `-ec` argument that shows how the binary is run. This should not be changed; it is hardcoded to a location inside the cornflakes repo.
- `-lc` argument: This specifies the parameters that will be looped over for the
  particular experiment (e.g., the exact parameters to load the experiment, and
exact rates to use in the throughput latency curve). Changing this changes the
parameters the experiment will run over.

## Known Issues
### Expected time estimates in script output is wrong
The python scripts themselves print out the number of trials that will be run,
current percentage done, and expected time.
The "expected time" estimate is likely slightly wrong (instead, see the times we
list along with each experiment), especially if you restart
the experiment in the middle and it picks up again midway through.
These estimates were used while developing to schedule/plan out experiments
better.

### "Failed to ssh due to not being able to open file descriptor"
For the longer running experiments (more than a few hours), the python scripts sometimes fail to ssh and stop running.
The error is due to the script not being able to open file descriptors
transiently for the ssh connections.
Increasing the allowed number of file descriptors on the server machine with `ulimit -n 1048576` should
help.
If the script stopped, you can restart it and it will pick off where
it left off.
Note that once you restart, the expected time estimates printed inside the
script may be off.

# Hello world example (~2-3 minutes)

# Reproducing results.
## Figure 8 (Redis comparison over twitter traces)
### Experiment time overview (5-6 hours compute, 2-3 min human).
This script takes about 5-6 hours to run. It runs two throughput latency curves
(Cornflakes serialization and Redis serialization inside Redis) of 39 points
each; each point runs for about 30 seconds; however, the server loads the values
into memory for each point causing each trial to take closer to two minutes.

### Instructions
```
## ssh into the server node on cloudlab
ssh $USER@cornflakes-server-IP
cd /mydata/$USER/cornflakes-scripts
## run inside tmux or screen
./twitter-traces-redis.sh
```

### Initial expected outputs


### Expected output location
| Figure | Filepath |
| --- | ----------- |
| Figure 8 |`/mydata/$USER/expdata/expdata/twitter_redis/plots/min_num_keys_4000000/value_size_0/ignore_sets_False/ignore_pps_True/distribution_exponential/baselines_p99_cr.pdf` |

To see median latency graph, replace `p99` with `median` in any of the graph
paths (these were not reported in the paper).


## Figure 7 and 12 (Cornflakes KV, running twitter trace.)
### Experiment Time (14-15 hours compute, 2-3 min human time)
This script takes around 14-15 hours to run.
It runs 6 throughput latency curves (Protobuf, Flatbuffers, Capnproto,
Cornflakes, and Cornflakes configured to only copy or only zero-copy); each
curve consists of about 40 throughput latency points and produces both the
baselines comparison results and hybrid comparison result.

### Instructions
```
ssh $USER@cornflakes-server-IP
cd /mydata/$USER/cornflakes-scripts
## run inside tmux or screen
./twitter-traces-cfkv.sh
```

### Initial expected outputs


### Expected output location
| Figure | Filepath |
| --- | ----------- |
| Figure 7 (comparing baselines) |`mydata/$USER/expdata/twitter_cfkv/plots/min_num_keys_4000000/value_size_0/ignore_sets_False/ignore_pps_True/distribution_exponential/baselines_p99_cr.pdf` |
| Figure 12 (hybrid comparison) |`mydata/$USER/expdata/twitter_cfkv/plots/min_num_keys_4000000/value_size_0/ignore_sets_False/ignore_pps_True/distribution_exponential/thresholdvary_p99_cr.pdf` |

To see median latency graph, replace `p99` with `median` in any of the graph
paths (these were not reported in the paper).

## Figure 5 Partial (threshold heatmap)
### Experiment Time (23-24 hours compute, 2-3 min human time)
This script takes almost a full day. It runs the datapoints required to compute
the `1024` and `2048` vertical columns of the heatmap in Figure 5 and validates
the threshold choice of 512; all vertical
columns would take a few more days.


### Instructions
```
ssh $USER@cornflakes-server-IP
cd /mydata/$USER/cornflakes-scripts
## run inside tmux or screen
./mmtstudy.sh
```

### Expected output location
| Figure | Filepath |
| --- | ----------- |
| Figure 5 subset|`/mydata/$USER/expdata/threshold_heatmap/plots/heatmap_anon.pdf` |

### Running the entire Figure 5 (optional)
If you are interested in recreating the entire Figure 5, modify `mmtstudy.sh`
so the `-lc` argument takes in `-lc /mydata/$GENIUSER/cornflakes-scripts/yamls/fig5.yaml`;
this yaml specifies the iterations for recreating the entire heatmap.

## Figure 6 (custom kv store with google trace, optional)
### Experiment Time (3 hours compute, 2-3 min human time)
This experiment runs the custom kv store with the google trace on the software
baselines; it just does the version where the values are lists of 1-8 elements.

### Instructions
```
ssh $user@cornflakes-server-ip
cd /mydata/$user/cornflakes-scripts
## run inside tmux or screen
./google-traces.sh
```

### Expected output location
| Figure | Filepath |
| --- | ----------- |
| Figure 6 |`googleproto_cfkv/plots/max_num_values_8/total_num_keys_1000000/key_size_64/distribution_exponential/baselines_p99_cr.pdf`|

## Table 2 (CDN trace, optional)
### Experiment Time (3 hours compute, 2-3 min human time)

### Instructions
```
ssh $USER@cornflakes-server-IP
cd /mydata/$USER/cornflakes-scripts
## run inside tmux or screen
./cdn-traces.sh
```

### Expected output location
The python script calculates the highest achieved load across all offered loads
for each system; you can use the `format-cdn.sh` bash script in the
`cornflakes-scripts` repo to format the log.
| Figure | Filepath | Format Command |
| --- | ----------- | -------------- |
 Table 2 | `/mydata/$USER/expdata/cdn_cfkv/latencies-postprocess.log` | `/mydata/$USER/cornflakes-scripts/format-cdn.sh /mydata/$USER/expdata/cdn_cfkv/latencies-postprocess.log`

