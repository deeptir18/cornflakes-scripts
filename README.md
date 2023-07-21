# cornflakes-scripts
This repository contains scripts to run and reproduce results from the SOSP paper,
Cornflakes: Zero-Copy Serialization for Microsecond-Scale Networking,
conditionally accepted at SOSP 2023, on Cloudlab.
The scripts in this repository assume you have setup machines
via the custom cloudlab-profile linked below; this profile 
sets up Cloudlab machines with all the necessary dependencies.
The scripts assume certain filepaths (i.e., cornflakes is located at
/mydata/$USER/cornflakes) which the cloudlab profile sets up automatically.
The traces used in the evaluation are located in a Cloudlab
long-term dataset; the cloudlab profile mounts the traces on an NFS server the
nodes have access to and copies the data to node-local storage on startup.
The end of the README (as well as the main Cornflakes repository) contains
instructions for how to get started with Cornflakes on your own hardware.

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

# Cloudlab profile instructions (1 hour machine time, 15 minutes human time)
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
The cloudlab profile is located [here](https://www.cloudlab.us/p/955539a31b0c7be330933414edd8d4af54f7dbec). Please instantiate the profile with the latest `main` default branch.
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
2. 
## Configuring machine after experiment instantiation.
0. After the cloudlab UI indicates that the startup scripts have _finished_
   running, please reboot (power cycle) each of the machines. This loads the newly installed
Mellanox drivers.
1. After the cloudlab UI indicates the machines have rebooted, please log into each of the server and client nodes and run the
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

2. Machine settings. On each machine, log in and run the following:
```
## installs hugetlbfs
sudo /mydata/$USER/cornflakes/install/install-hugepages.sh 7500
## disables c-states
sudo /mydata/$USER/cornflakes/install/set_freq.sh
```


3. Configure config file. To run any cornflakes experiments, Cornflakes requires a config file that
   looks like [sample config](sample_config.md). Please fill in at
`/mydata/$USER/config/cluster_config.yaml`; this is the location that all the
scripts expect.
   - PCI address && hardware interface: 
        1. [Server] ssh into the server and run `ifconfig`. See which interface
           name matches the assigned ip 192.168.1.1. For d6525-100g machines,
           this is likely ens1f0np0 or ens1f0np1 depending on which port (0 or
           1) was used. The corresponding ethernet hardware address is the one
           we want.
        2. [Client] ssh into the client and run `ifconfig`. See which interface
           name matches the assigned ip 192.168.1.2 (or higher for more clients). For d6525-100g machines,
           this is likely ens1f0np0 or ens1f0np1 depending on which port (0 or
        3. Given an interface name, run `sudo ethtool -i <iface_name> to find
           the PCI address.
    - SSH IPs:
        1. Given the DNS names of the cloudlab servers, get the IPs used to ssh
           which the scripts require internally, e.g., by using ifconfig and
           looking at the ssh interface or by running dig on the DNS name (e.g.,
           `dig amdXXX@cloudlab.utah.us`).
    - `dpdk` section of config:
        - Replace the fourth entry of the `eal_init` section below with the PCI
          address of that machine.
        - Replace the `pci_addr` section with the PCI address.
        - Replace port with 0, or 1, depending on if the interface name ends
          with 0 or 1.
    - `mlx5` section of the config:
        - Replace `pci_addr` witht he pci address of the interface.
    - `lwip` section (common to server and client configs):
        - Replace the "XX:XX:XX..." with the ethernet address of mapping to the
          192.168.1.1 IP on the server.
        - For each client, do the same (client-1 is 192.168.1.2, client-2 is
          192.168.1.3...)
    - `hosts` section (common to server and client configs):
        - Replace the addr field with the correct SSH ip address for each
          machine.
        - Replace the mac field for the correct NIC mac address for each
          machine.
    - Replace `$USER` with your username.
    - If there is more than 1 client, add `client2`, `client3`... to
      `host_types[client]` and change `max_clients` to the number of clients.

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
necessary to run the experiment described. The form of the bash script is
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
Here is information about each parameter. Note that if you choose to change the
location of the cluster config file from what the cloudlab profile setup, or the
Cornflakes repo, please change the paths in the corresponding bash script.
- The `$PATH_TO_CLUSTER_CONFIG` is hardcoded in each script to
`/mydata/$USER/config/cluster_config.yaml`; this is where the setup instructions
above specified the yaml should be.
- `$PATH_TO_RESULTS` is hardcoded to `/mydata/$USER/expdata/<expname>`
- `$PATH_TO_CORNFLAKES` is hardcoded to `/mydata/$USER/cornflakes`. If cornflakes
  is at a different location, please change this substitution.
- `-ec` argument: Each program has a yaml that specifies the command line (for both the server and client) specified by the `-ec` argument that shows how the binary is run. This is hardcoded to a path inside the Cornflakes repo.
- `-lc` argument: This specifies the parameters that will be looped over for the
  particular experiment (e.g., the exact parameters to load the experiment, and
exact rates to use in the throughput latency curve).

# Hello world example (~2-3 minutes)

# Reproducing results.
## Figure 8 (Redis comparison over twitter traces)
### Experiment time overview.
This script takes about 5-6 hours to run. It runs two throughput latency curves
(Cornflakes serialization and Redis serialization inside Redis) of 39 points
each; each point runs for about 30 seconds; however, the server loads the values
into memory for each point causing each trial to take closer to two minutes.

### Instructions
```
## ssh into the server node on cloudlab
ssh $USER@cornflakes-server-IP
cd /mydata/$USER/cornflakes-scripts
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
### Time
This script takes around 14-15 hours to run.
It runs 6 throughput latency curves (Protobuf, Flatbuffers, Capnproto,
Cornflakes, and Cornflakes configured to only copy or only zero-copy); each
curve consists of about 40 throughput latency points and produces both the
baselines comparison results and hybrid comparison result.

### Instructions
```
ssh $USER@cornflakes-server-IP
cd /mydata/$USER/cornflakes-scripts
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

## Figure 5 (threshold heatmap)
### Time

### Instructions

### Expected output location

## Figure 6 (custom kv store with google trace, optional)
### Time

### Instructions

### Expected output location

## Table 2 (CDN trace, optional)
### Time

### Instructions

### Expected output location
