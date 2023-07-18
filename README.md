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
## Dataset
## Hardware
## Profile
## Configuring machine after experiment instantiation.
1. After the cloudlab experiment summary indicates the initialization scripts have
finished running, please log into each of the server and client nodes and run the
following. Note that `$USER` refers to your cloudlab username.
```
## installs hugetlbfs
sudo /mydata/$USER/cornflakes/install/install-hugepages.sh 7500
## turns of any turboboost related settings by enabling a constant frequency
sudo /mydata/$USER/cornflakes/install/set_freq.sh
```
2. To run any cornflakes experiments, Cornflakes requires a config file that
   looks like the following. Please fill in at `/mydata/$USER/config/cluster_config.yaml`
   - PCI address && hardware interface: 
        1. [Server] ssh into the server and run `ifconfig`. See which interface
           name matches the assigned ip 192.168.1.1. For d6525-100g machines,
           this is likely ens1f0np0 or ens1f0np1 depending on which port (0 or
           1) was used. The corresponding ethernet hardware address is the one
           we want.
        2. [Client] ssh into the client and run `ifconfig`. See which interface
           name matches the assigned ip 192.168.1.1. For d6525-100g machines,
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
```
# # Copyright (c) Microsoft Corporation.
# # Licensed under the MIT license.

dpdk:
    eal_init: ["-n", "4", "-a", "0000:41:00.0,txq_inline_mpw=256,txqs_min_inline=0","--proc-type=auto"]
    pci_addr: "0000:41:00.0" ## run sudo ethtool -i iface_name to find pci_addr
    port: 0 ## either 1 or 0 depending on which port is configured for the
    experiment interface
mlx5:
    pci_addr: "0000:41:00.0"

lwip:
  known_hosts:
    "XX:XX:XX:XX:XX:XX": 192.168.1.1 # cornflakes-server
    "XX:XX:XX:XX:XX:XX": 192.168.1.2 # cornflakes-client1

port: 54323 # for the server
client_port: 12345

host_types:
  server: ["server"]
  client: ["client1"]

hosts:
    server:
        addr: 128.110.219.136 # IP for ssh
        ip: 192.168.1.1
        mac: "XX:XX:XX:XX:XX:XX" # should match above
        tmp_folder: "/mydata/$USER/cornflakes_tmp
        cornflakes_dir: "/mydata/$USER/cornflakes"
        config_file: "/mydata/config/cluster_config.yaml"

    client1:
        addr: 128.110.219.126 # IP for ssh
        ip: 192.168.1.2
        mac: "XX:XX:XX:XX:XX:XX"
        tmp_folder: "/mydata/$USER/cornflakes_tmp
        cornflakes_dir: "/mydata/$USER/cornflakes"
        config_file: "/mydata/config/cluster_config.yaml"
    
cornflakes_dir: /mydata/$USER/cornflakes
max_clients: 1 #  2 for 2 clients.
user: $USER
config_file: /mydata/$USER/config/cluster_config.yaml
```

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



