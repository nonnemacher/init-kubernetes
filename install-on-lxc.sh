#!/bin/bash

# Configurações
declare lxd="sudo /snap/bin/lxd"
declare lxc="sudo /snap/bin/lxc"
declare get="sudo apt"

# Configurações Node
declare name="${1}"
declare network="${2}"
declare version="ubuntu:16.04"

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
${lxc} init ${version} ${name} -c security.privileged=true -c security.nesting=true -c linux.kernel_modules=ip_tables,ip6_tables,netlink_diag,nf_nat,overlay
#printf "lxc.cap.drop=\nlxc.aa_profile=unconfined\n" | ${lxc} config set kubernetes raw.lxc -

sleep 5

echo ":::: "
echo ":::: Init Network - LXC - ${network} "
echo ":::: "
${lxc} network create ${network} ipv4.address=auto ipv4.nat=true ipv6.address=none ipv6.nat=false

sleep 5

echo ":::: "
echo ":::: Init Network - ${network} to ${name} "
echo ":::: "
${lxc} network attach ${network} ${name}

echo ":::: "
echo ":::: Init LXC ${name} on ${version} "
echo ":::: "
${lxc} start ${name}
sleep 10

echo ":::: "
echo ":::: Update LXC ${name}-${version}"
echo ":::: "
${lxc} exec ${name} -- ${get} remove lxd -y
${lxc} exec ${name} -- ${get} update
${lxc} exec ${name} -- ${get} upgrade -y
${lxc} exec ${name} -- ${get} install squashfuse curl apt-transport-https docker.io -y
${lxc} exec ${name} -- ln -s /bin/true /usr/local/bin/udevadm

echo ":::: "
echo ":::: LXC ${name}-${version} init lxd "
echo ":::: "
${lxc} exec ${name} -- sudo snap install lxd
${lxc} exec ${name} -- sudo snap install conjure-up --classic
${lxc} exec ${name} -- sh -c "curl https://packages.cloud.google.com/apt/doc/apt-key.gpg > /root/apt-key.gpg"
${lxc} exec ${name} -- apt-key add /root/apt-key.gpg
${lxc} exec ${name} -- sh -c "echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' > /etc/apt/sources.list.d/kubernetes.list"
${lxc} exec ${name} -- ${get} update
${lxc} exec ${name} -- ${get} install kubelet kubeadm kubectl kubernetes-cni -y
${lxc} exec ${name} -- bash
