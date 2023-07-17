# cornflakes-scripts
This repository contains scripts to run and reproduce from the SOSP paper,
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
This repository assumes (cornflakes)[https://github.com/deeptir18/cornflakes], on the main branch, at XXXX commit hash,
and the cloudlab profile pointing to (this repository)[https://github.com/deeptir18/cornflakes-cloudlab-profile/] at main and XXXX commit hash. We briefly describe the code structure of Cornflakes below (TODO)
```
cornflakes
    - cf-kv:  source code for kv store application
    - cornflakes-codegen: boilerplate for generating 
    - cornflakes-libos: common serialization and datapath code
    - cornflakes-utils: common utilities for running binaries
```

# Cloudlab profile instructions (1 hour machine time, 15 minutes human time)
## Profile
## Dataset
## Hardware

# Results reproduced overview
We have provided instructions to reproduce results for all experiments described
in the paper except for Figure 9 (TCP integration), Figure 10 (Intel vs.
mellanox NICs) and Figure 13 (scalability). The Intel vs. mellanox NIC
experiment was performed on a private cluster that others cannot access; Cloudlab does not have the Intel NICs we used. However, we provide
instructions in the [Cornflakes readme](https://github.com/deeptir18/cornflakes)
for getting started with Intel NICs. The TCP server integration code is available [here](https://github.com/deeptir18/demikernel/tree/cornflakes); however, this code has a completely different setup (it runs atop Demikernel and uses a different,[TCP load generator](https://github.com/sansri264/tcp_generator)).
We provide some instructions for Figure 13, but they use a different version
of the microbenchmark code, so requires a few more manual steps.

# Hello world example (~2-3 minutes)

# Reproducing results.
## Figure 2 (serialization throughput today)
### Time

### Instructions


### Expected output location

## Figure 3 (scatter-gather microbenchmark)
### Time

### Instructions


### Expected output location

## Figure 5 (threshold heatmap)
### Time

### Instructions

### Expected output location

## Table 1, Figure 6, Table 4 (custom kv store with google trace)
### Time

### Instructions


### Expected output location
*Table 1*

*Figure 6*

*Table 4*

## Figure 7, Figure 12 (custom kv store with twitter trace)
### Time

### Instructions

### Expected output location

## Figure 8 (redis with twitter trace)
### Time

### Instructions

### Expected output location

## Table 3 (redis with ycsb traces)
### Time

### Instructions

### Expected output location

## Table 5 (combined serialize and send, optional)
### Time

### Instructions

### Expected output location
*Google trace*

*Twitter trace*

*YCSB trace*

## Figure 11 (cycles breakdown, optional)

## Figure 13 (scalability, optional)
### Time

### Instructions

### Expected output location



