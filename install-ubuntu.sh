#!/bin/bash
source install-lxd.sh

# Configuração do Ubuntu
declare name="${1}" # Nome do container
declare network="${2}" # Nome da network
declare version="ubuntu:16.04"

echo -e "\n"
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: "
echo ":::: Removendo container \"${name}\" e network \"${network}\""
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: "
echo -e "\n"
${lxc} delete ${name} -f
${lxc} network delete ${network}

echo -e "\n"
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: "
echo ":::: Criando container com o nome de \"${name}\""
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: "
echo -e "\n"
${lxc} init ${version} ${name} -c security.privileged=true -c security.nesting=true -c linux.kernel_modules=ip_tables,ip6_tables,netlink_diag,nf_nat,overlay

echo -e "\n"
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: "
echo ":::: Criando network \"${network}\" e vinculando ao \"${name}\""
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: "
echo -e "\n"
${lxc} network create ${network} ipv4.address=auto ipv4.nat=true ipv6.address=none ipv6.nat=false
${lxc} network attach ${network} ${name}

echo -e "\n"
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: "
echo ":::: Iniciando contatiner \"${name}\" - 10s de delay para continuar"
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: "
echo -e "\n"
${lxc} start ${name}
sleep 10

echo -e "\n"
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: "
echo ":::: Atualizando contatiner \"${name}\""
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: "
echo -e "\n"
${lxc} exec ${name} -- ${get} update
${lxc} exec ${name} -- ${get} upgrade -y
