#!/bin/bash

declare network="kubbr0"
declare name="kubernetes"
declare version="ubuntu:16.04"

alias lxd="/snap/bin/lxc"
alias lxc="/snap/bin/lxc"
alias get="sudo apt-get"

echo ":::: "
echo ":::: Remover LXD "
echo ":::: "

get remove lxd -y

echo ":::: "
echo ":::: Update Linux "
echo ":::: "

get update -y

echo ":::: "
echo ":::: Update Linux "
echo ":::: "

get upgrade -y

echo ":::: "
echo ":::: Install Snap "
echo ":::: "

get install snap -y

echo ":::: "
echo ":::: Install Snap - LXD "
echo ":::: "

sudo snap install lxd

echo ":::: "
echo ":::: Init Snap - LXD "
echo ":::: "

sudo lxd init --auto

echo ":::: "
echo ":::: Init Network - LXC - ${network} "
echo ":::: "

sudo lxc network create ${network} ipv4.address=auto ipv4.nat=true ipv6.address=none ipv6.nat=false

echo ":::: "
echo ":::: Config Sys "
echo ":::: "

sudo sysctl fs.inotify.max_user_instances=1048576
sudo sysctl fs.inotify.max_queued_events=1048576
sudo sysctl fs.inotify.max_user_watches=1048576
sudo sysctl vm.max_map_count=262144

echo ":::: "
echo ":::: Init LXC - ${name} on ${version} "
echo ":::: "

sudo lxc init ${version} ${name} -c security.privileged=true -c security.nesting=true -c linux.kernel_modules=ip_tables,ip6_tables,netlink_diag,nf_nat,overlay
printf "lxc.cap.drop=\nlxc.aa_profile=unconfined\n" | lxc config set kubernetes raw.lxc -

echo ":::: "
echo ":::: Init Network - ${network} to ${name} "
echo ":::: "

sudo lxc network attach ${network} ${name}

echo ":::: "
echo ":::: Init LXC Kubernetes on Ubuntu 16.04 "
echo ":::: "

lxc start kubernetes
