sudo apt install dnsutils iputils-ping -y

sudo nano /etc/hosts

"
192.168.33.91 openstack1
192.168.33.92 openstack2
"
ssh-keygen -t rsa
ssh-copy-id -i ~/.ssh/id_rsa.pub loki@openstack1
ssh-copy-id -i ~/.ssh/id_rsa.pub loki@openstack2