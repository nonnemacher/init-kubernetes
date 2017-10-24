#!/bin/bash

# Configurações
declare lxd="sudo /snap/bin/lxd"
declare lxc="sudo /snap/bin/lxc"
declare get="sudo apt"

# Configurações Kuberntes
declare network="kubbr0"
declare storage="kubdir0"
declare name="kubernetes"
declare version="ubuntu:16.04"

echo ":::: "
echo ":::: Remover LXD "
echo ":::: "
${get} remove lxd -y

echo ":::: "
echo ":::: Update Linux "
echo ":::: "
${get} update -y

echo ":::: "
echo ":::: Update Linux "
echo ":::: "
${get} upgrade -y

echo ":::: "
echo ":::: Install Snap "
echo ":::: "
${get} install snap -y

echo ":::: "
echo ":::: Install Snap - LXD "
echo ":::: "
sudo snap install lxd

echo ":::: "
echo ":::: Init Snap - LXD "
echo ":::: "
${lxd} init --auto

echo ":::: "
echo ":::: Init Network - LXC - ${network} "
echo ":::: "
${lxc} network create ${network} ipv4.address=auto ipv4.nat=true ipv6.address=none ipv6.nat=false

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
printf "lxc.cap.drop=\nlxc.aa_profile=unconfined\n" | lxc config set kubernetes raw.lxc -

echo ":::: "
echo ":::: Init Network - ${network} to ${name} "
echo ":::: "
${lxc} network attach ${network} ${name}

echo ":::: "
echo ":::: Init LXC ${name} on ${version} "
echo ":::: "
${lxc} start kubernetes
sleep 15

echo ":::: "
echo ":::: Update LXC ${name}-${version}"
echo ":::: "
${lxc} exec ${name} -- ${get} remove lxd -y
${lxc} exec ${name} -- ${get} update
${lxc} exec ${name} -- ${get} upgrade -y
${lxc} exec ${name} -- ${get} install squashfuse -y
${lxc} exec ${name} -- ln -s /bin/true /usr/local/bin/udevadm

echo ":::: "
echo ":::: LXC ${name}-${version} init lxd "
echo ":::: "
${lxc} exec ${name} -- sudo snap install lxd
${lxc} exec ${name} -- sudo snap install conjure-up --classic
${lxc} exec ${name} -- sudo /snap/bin/lxd init --auto
${lxc} exec ${name} -- sudo /snap/bin/lxc network create ${network} ipv4.address=auto ipv4.nat=true ipv6.address=none ipv6.nat=false
${lxc} exec ${name} -- sudo /snap/bin/lxc storage create ${storage} dir
${lxc} exec ${name} -- sudo -u ubuntu -i conjure-up kubernetes
