#!/bin/bash

# Configurações
declare lxd="sudo /snap/bin/lxd"
declare lxc="sudo /snap/bin/lxc"
declare get="sudo apt"

echo -e "\n"
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: "
echo ":::: Preparando Ubuntu"
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: "
echo -e "\n"
${get} remove lxd -y && ${get} update && ${get} upgrade -y

echo -e "\n"
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: "
echo ":::: Instalando SNAP e LXD "
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: "
echo -e "\n"
${get} install snap -y && sudo snap install lxd

echo -e "\n"
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: "
echo ":::: Iniciando LXD"
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: "
echo -e "\n"
${lxd} init --auto
