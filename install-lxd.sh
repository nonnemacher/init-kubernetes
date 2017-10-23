declare network="kubbr0"
declare lxc="/snap/bin/lxc"
declare get="sudo apt-get"

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
sudo lxd init --auto

echo ":::: "
echo ":::: Init Network - LXC - ${network} "
echo ":::: "
sudo lxc network create ${network} ipv4.address=auto ipv4.nat=true ipv6.address=none ipv6.nat=false
