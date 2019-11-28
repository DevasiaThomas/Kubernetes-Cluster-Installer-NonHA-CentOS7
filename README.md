# Kubernetes-Cluster-Installer-NonHA-CentOS7
Scripts to install a Non HA cluster on CentOS7 with everything upgraded. Uses Calico and installs helm 3 as well

## Usage

All scripts are required to be run as **root** (not r00t  - your machine is probably compromised if you see that user. If you believe it's not compromised - *wink* *wink*). If the scripts aren't already executable, supply execute permissions to them. Follow the below sequentially.

### Prime your CO7 Systems

The ``centos7.sh`` script updates your system dependencies and gets the kernel to the latest version (at the time this was written), you can change that to your liking. Running this will reboot your system at the end of it. Don't worry if you are doing this over ssh, it is safe to do so. The connection will drop - you can ssh in again after a while.

Run this in parallel on all your systems that will participate in this cluster. Helps save some time (Who am I kidding, it saves a lot of time. Shia Labeouf commands you to just do it!!).

### K8s Installation

#### Master Node Selection
We only have one master here, so chose a machine that will serve as your master. I choose the weakest out of the pool, in terms of resources, to be my master node. This is because I don't allow pods (apart from K8 infrastructure ones) to be deployed on this. I think that's the case by default. If you plan on changing that (you're the boss), make sure your master is slightly beefier (MO POWAH BABEH!) than the worker nodes.

#### Insecure Registries Configuration for Docker Daemon
This script installs docker as the container service for K8. You may want to pull images from insecure repositories, coz why not! (You always wanted to go on the dark web, some tor stuff - but didn't want to take the plunge? Insecure repos are the dark-much-safer-side of container repos - you don't know what images you will consume here. But don't worry they are not the visual kind).
 Anyways, there is a line that is commented out in ``centos7-master.sh`` and ``centos7-worker.sh`` that looks like this

``#  "insecure-registries": ["ip/subnet", "name:port"],``

Uncomment that and fill it with values if required. Remember to save the file - it happens to the best of us ( It hasn't happened to me yet -- must mean I'm not the best. Screw you universe!).

#### Installation starts here
Now on your chosen master node, run ``centos7-master.sh`` and in parallel (remember Shia is commanding you), on all your worker nodes, run ``centos7-worker.sh``. If you wish to see exactly what my script is doing run them using ``sh -x``, for that gorgeous, wonderful, amazing detail that's almost lets you enter the matrix.

Once the master node installation completes, it will dump some output that looks like this

```
To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join ip:6443 --token gibberish \
    --discovery-token-ca-cert-hash sha256:encrypted-code-to-launch-god-knows-what
```
Pay attention only to the ``kubeadm join`` command. Everything else has already been taken care of. You need to run this on all your worker nodes when the installation on those nodes completes. 

Once you are done doing that, congratulations - you have installed this THING after this long arduous journey that even Frodo wouldn't take (I hope you didn't do this on your weekend). Go run some pods! (Don't eat them).

Ooh,  btw if you ever lose the ``kubeadm join`` command run ``kubeadm token create --print-join-command`` to get a new one. You're welcome :) Peace out!
