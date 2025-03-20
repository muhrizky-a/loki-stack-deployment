#Sourcing OpenStack RC File
cat /etc/kolla/admin-openrc.sh

for key in $( set | awk '{FS="="}  /^OS_/ {print $1}' ); do unset $key ; done
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=admin
export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=<Kolla generated admin password>
export OS_AUTH_URL=http://10.10.10.100:35357/v3
export OS_INTERFACE=internal
export OS_ENDPOINT_TYPE=internalURL
export OS_IDENTITY_API_VERSION=3
export OS_REGION_NAME=RegionOne
export OS_AUTH_PLUGIN=password

source /etc/kolla/admin-openrc.sh

source ~/kolla-venv/bin/activate
openstack endpoint list

#Creating CirrOS Image
source ~/kolla-venv/bin/activate

wget http://download.cirros-cloud.net/0.5.2/cirros-0.5.2-x86_64-disk.img
wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
wget https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img

openstack image create --disk-format qcow2 \
  --container-format bare --public \
  --file ./cirros-0.5.2-x86_64-disk.img cirros-0.5.2-loki

openstack image create --disk-format iso \
  --container-format bare --public \
  --file ./ubuntu-22.04.4-live-server-amd64.iso ubuntu-22.04-live

openstack image create --disk-format qcow2 \
  --container-format bare --public \
  --file ./ubuntu-22.04-server-cloudimg-amd64.img ubuntu-22.04-server-cloudimg-amd64

openstack image create --disk-format qcow2 \
  --container-format bare --public \
  --property os_distro='ubuntu' \
  --file ./jammy-server-cloudimg-amd64.img jammy-server-cloudimg-amd64



openstack image list
openstack image show cirros-0.5.2-loki

# fedora image (supported by Magnum)
export FCOS_VERSION="35.20220116.3.0"
wget https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/${FCOS_VERSION}/x86_64/fedora-coreos-${FCOS_VERSION}-openstack.x86_64.qcow2.xz
unxz fedora-coreos-${FCOS_VERSION}-openstack.x86_64.qcow2.xz
openstack image create \
                      --disk-format=qcow2 \
                      --container-format=bare \
                      --file=fedora-coreos-${FCOS_VERSION}-openstack.x86_64.qcow2 \
                      --property os_distro='fedora-coreos' \
                      fedora-coreos-latest-public

#Creating External Network
openstack network create  --share --external \
  --provider-physical-network physnet1 \
  --provider-network-type flat external-net-loki



sudo cat /etc/kolla/neutron-server/ml2_conf.ini | grep flat_network | awk '{print $3}'

openstack subnet create --network external-net-loki \
  --gateway 192.168.137.1 --no-dhcp \
  --subnet-range 192.168.137.0/24 \
  --dns-nameserver 8.8.8.8  external-subnet-loki-eth

openstack subnet create --network external-net-loki \
  --gateway 192.168.2.1 --no-dhcp \
  --subnet-range 192.168.2.0/24 external-subnet-loki-new

openstack subnet create --network external-net-loki \
  --gateway 10.10.102.1 --no-dhcp \
  --subnet-range 10.10.102.0/24 \
  --dns-nameserver 8.8.8.8 \
  external-subnet-loki-lab

openstack network list
openstack network show external-net-loki
openstack subnet show external-subnet-loki

#Creating Internal Network
openstack network create internal-net-loki

openstack subnet create --network internal-net-loki \
  --allocation-pool start=192.168.100.200,end=192.168.100.254 \
  --dns-nameserver 8.8.8.8 --gateway  192.168.100.1 \
  --subnet-range 192.168.100.0/24 internal-subnet-loki

openstack network list
openstack subnet list
openstack network show internal-net-loki
openstack subnet show internal-subnet-loki

#Creating a Router
openstack router create router-loki
openstack router set --external-gateway external-net-loki router-loki
openstack router add subnet router-loki internal-subnet-loki

openstack router list
openstack router show router-loki


#Creating Security Group
openstack security group create security-group-allow-ssh-icmp-kube --description 'Allow SSH, ICMP, and Kubernetes Ports'
openstack security group rule create --protocol icmp security-group-allow-ssh-icmp-kube
openstack security group rule create --protocol tcp --ingress --dst-port 22 security-group-allow-ssh-icmp-kube
openstack security group rule create --protocol tcp --ingress --dst-port 3000 security-group-allow-ssh-icmp-kube
openstack security group rule create --protocol tcp --ingress --dst-port 443 security-group-allow-ssh-icmp-kube
openstack security group rule create --protocol tcp --ingress --dst-port 6443 security-group-allow-ssh-icmp-kube
openstack security group rule create --protocol tcp --ingress --dst-port 30000:32767 security-group-allow-ssh-icmp-kube


openstack security group list
openstack security group rule list security-group-allow-ssh-icmp

#Creating Keypair
openstack keypair create --public-key ~/.ssh/id_rsa.pub controller-key

openstack keypair list
openstack keypair show controller-key

#Creating Flavor
openstack flavor create --ram 512 --disk 8 --vcpus 1 --public c1-small-loki
openstack flavor create --id m1.tiny --ram 512 --disk 8 --vcpus 1 --public m1.tiny
openstack flavor create --id m1.medium --ram 4096 --disk 40 --vcpus 2 --public m1.medium
openstack flavor create --id m1.medium.kube --ram 4096 --disk 20 --vcpus 2 --public m1.medium.kube

openstack flavor list
openstack flavor show c1-small-loki

#Affinity creation
openstack aggregate create <aggregate_name> --availability-zone <zone_name>
openstack aggregate add host <aggregate_name> <host_name>

#Launching an Instance on specific node
openstack server create --flavor <flavor> --image <image> --availability-zone nova:<compute2> <server_name>
openstack server create --flavor <flavor> --image <image> --availability-zone <aggregate_name> <instance_name>

#Launching an Instance
openstack server create --flavor c1-small-loki \
  --image cirros-0.5.2-loki \
  --key-name controller-key \
  --security-group security-group-allow-ssh-icmp \
  --network internal-net-loki \
  cirros-instance

openstack server create --flavor m1.tiny \
  --image cirros-0.5.2-loki \
  --key-name controller-key \
  --security-group security-group-allow-ssh-icmp-kube \
  --network internal-net-loki \
  cirros-instance-2

openstack server create --flavor m1.medium \
  --image jammy-server-cloudimg-amd64  \
  --key-name controller-key \
  --security-group security-group-allow-ssh-icmp \
  --network internal-net-loki \
  jammy-instance

openstack server create --flavor m1.medium.kube \
  --image jammy-server-cloudimg-amd64  \
  --key-name controller-key \
  --security-group security-group-allow-ssh-icmp-kube \
  --network internal-net-loki \
  kube-master-instance

openstack server create --flavor m1.medium \
  --image ubuntu-22.04-server-cloudimg-amd64   \
  --key-name controller-key \
  --security-group security-group-allow-ssh-icmp \
  --network internal-net-loki \
  ubuntu-2204-cloudimg-instance

openstack server list
openstack server show cirros-instance-loki

#Attach Floating IP to Instance
openstack floating ip create --floating-ip-address 20.20.20.100 external-net-loki
openstack server add floating ip cirros-instance-loki 20.20.20.100
openstack floating ip create --floating-ip-address 20.20.20.101 external-net-loki
openstack server add floating ip cirros-instance 20.20.20.101

openstack floating ip create external-net-loki
openstack server add floating ip ubuntu-instance 192.168.2.153
openstack server add floating ip master-instance 192.168.2.153
openstack server remove floating ip master-instance 192.168.137.12
openstack server list

#create snapshot
 openstack server image create kube-master-instance --name jammy-kubeadm-snapshot

#create instance with snapshot
openstack server create --flavor m1.medium.kube \
  --image jammy-kubeadm-snapshot  \
  --key-name controller-key \
  --security-group security-group-allow-ssh-icmp-kube \
  --network internal-net-loki \
  worker-instance

#Access Your Instance using SSH
ssh -o 'PubkeyAcceptedKeyTypes +ssh-rsa' cirros@20.20.20.100
ssh -o 'PubkeyAcceptedKeyTypes +ssh-rsa' cirros@20.20.20.101

 ssh-keygen -f "/home/loki/.ssh/known_hosts" -R "192.168.33.236"

cat /etc/os-release 
ping -c 4 google.com
ChallengeResponseAuthentication yes


# Delete
openstack server delete cirros-instance
openstack floating ip delete 10.0.240.100
openstack router unset --external-gateway router-loki
openstack router delete router-loki
openstack subnet delete external-subnet-loki
openstack network delete external-net-loki
