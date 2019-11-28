# Kubernetes-Cluster-Installer-NonHA-CentOS7
Scripts to install a Non HA cluster on CentOS7 with everything upgraded. Uses Calico and installs helm 3 as well

## Usage

All scripts are required to be run as **root** user. If the scripts aren't already executable, supply execute permissions to them. Follow the below sequentially.

### Prime your CO7 Systems

The centos7.sh script updates your system dependencies and gets the kernel to the latest version (at the time this was written), you can change that to your liking. This will reboot your system at the end of it. Don't worry if you are doing this over ssh, it is safe to do so. The connection will drop - you can ssh in again after a while.

Run this in parallel on all your systems that will participate in this cluster. Helps save some time.

### K8 Installation

#### Master Node Selection
We only have one master here, so chose a machine that will serve as your master. I choose the weakest out of the pool, in terms of resources, to be my master node. This is because I don't allow pods (apart from K8 infrastructure ones) to be deployed on this. I think that's the case by default. If you plan on changing that (you're the boss), make sure your master is slightly beefier than the worker nodes.

#### Insecure Registries Configuration for Docker Daemon
This script installs docker as the container service for K8. You may want to pull images from insecure repositories, coz why not! Anyways, there is a line that is commented out in ``centos7-master.sh`` and ``centos7-worker.sh`` that looks like this

``#  "insecure-registries": ["ip/subnet", "name:port"],``

Now on this chosen master node, run centos7-master.sh
