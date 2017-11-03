#!/bin/bash
source install-ubuntu.sh minikube minikube

echo -e "\n"
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: "
echo ":::: Adicionado source kubernetes"
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: "
echo -e "\n"
${lxc} exec ${name} -- sh -c "curl https://packages.cloud.google.com/apt/doc/apt-key.gpg > /root/apt-key.gpg"
${lxc} exec ${name} -- apt-key add /root/apt-key.gpg
${lxc} exec ${name} -- sh -c "echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' > /etc/apt/sources.list.d/kubernetes.list"

echo -e "\n"
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: "
echo ":::: Instalando squashfuse, curl, apt-transport-https, docker.io, kubelet, kubeadm, kubectl, kubernetes-cni"
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: "
echo -e "\n"
${lxc} exec ${name} -- ${get} update
${lxc} exec ${name} -- ${get} install squashfuse curl apt-transport-https docker.io kubelet kubeadm kubectl kubernetes-cni -y

echo -e "\n"
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: "
echo ":::: Instalando minikube-linux-amd64 "
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: "
echo -e "\n"
${lxc} exec ${name} -- curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
${lxc} exec ${name} -- chmod +x minikube
${lxc} exec ${name} -- sudo mv minikube /usr/local/bin/
${lxc} exec ${name} -- minikube start --apiserver-name minikube --vm-driver none
${lxc} exec ${name} -- sh -c "cd /root/.minikube;
kubectl config --kubeconfig=minikube set-cluster minikube --server=https://kubernetes:8443 --certificate-authority=ca.crt --embed-certs=true;
kubectl config --kubeconfig=minikube unset users;
kubectl config --kubeconfig=minikube set-credentials minikube --client-key=client.key --client-certificate=client.crt --embed-certs=true;
kubectl config --kubeconfig=minikube set-context default --cluster=minikube --user=minikube;
kubectl config --kubeconfig=minikube use-context default "

echo -e "\n"
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: "
echo ":::: Configurando acesso "
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: "
echo -e "\n"
${lxc} exec ${name} -- ifconfig eth0 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}' > ~/.minikube-ip
${lxc} exec ${name} -- cat /root/.minikube/minikube > ~/.kubeconfig
sudo  sh -c "echo '`cat ~/.minikube-ip`  kubernetes' >> /etc/hosts"
sudo kubectl --kubeconfig ~/.kubeconfig get no
#sudo rm ~/.kubeconfig ~/.minikube-ip

echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: "
echo ":::: Iniciando Proxy - \"sudo kubectl --kubeconfig kubeconfig proxy\" "
echo ":::: Acesse > https://localhost:8001/ui "
echo ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: "
echo -e "\n"
sudo kubectl --kubeconfig ~/.kubeconfig proxy
