#!/bin/bash

#. /root/keystonercv3
. /home/izadorozhna/monsrc

start_nubmer=1
number_1=21
mons_num=241

name="_check_rt_case_$start_nubmer"

ext_net=""
master_internal_address=""
http_proxy=""
https_proxy=""

# see https://www.robustperception.io/icmp-pings-with-the-blackbox-exporter

#cat > /root/udd <<- "EOF"
cat << EOF > /root/udd
#cloud-config
password: 1
chpasswd: { expire: False }
ssh_pwauth: True
setup_prometheus:
  - &setup_prometheus |
    wget ${master_internal_address}:80/prometheus-node-exporter_0.15.2+ds-1_amd64.deb
    dpkg -i prometheus-node-exporter_0.15.2+ds-1_amd64.deb
    export http_proxy=${http_proxy}
    export https_proxy=${https_proxy}
    wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.12.0/blackbox_exporter-0.12.0.linux-amd64.tar.gz
    tar -xzf blackbox_exporter-*.linux-amd64.tar.gz
    cd blackbox_exporter-0.12.0.linux-amd64
    sudo ./blackbox_exporter&
runcmd:
  - [bash, -cex, *setup_prometheus]
EOF

openstack router create router_$name
router_uuid=$(openstack router show router_$name -c id | grep id | awk {'print $4'})
openstack router set --external-gateway $ext_net $router_uuid

ned1_id=$(openstack network create net1$name | grep "| id" | awk '{print $4}')
neutron subnet-create --name subnet1$name --gateway 192.168.$number_1.1 --allocation-pool start=192.168.$number_1.2,end=192.168.$number_1.254 --ip-version 4 net1$name 192.168.$number_1.0/24

#ned2_id=$(openstack network create net2$name  | grep "| id" | awk '{print $4}')
#neutron subnet-create --name subnet2$name --gateway 10.20.$number_2.1 --allocation-pool start=10.20.$number_2.2,end=10.20.$number_2.254 --ip-version 4 net2$name 10.20.$number_2.0/24

neutron router-interface-add router_$name subnet1$name
port_id=$(openstack port create --network mons-net --fixed-ip ip-address=192.168.101.$mons_num mon_port$name | grep "| id" |awk '{print $4}' )
openstack router add port router_$name $port_id

vm1=$(openstack server create --image Ubuntu1804-mons --flavor mons_slave --nic net-id=$ned1_id --security-group mons --security-group default --user-data /root/udd vm1$name | grep "| id" | awk '{print $4}')
#vm2=$(openstack server create --image Ubuntu1804 --flavor m1.medium --nic net-id=ad6ac89f-cde2-476e-8bca-6e831e285c1a --user-data /root/ud vm2$name | grep "| id" | awk '{print $4}')


#fip=$(openstack floating ip create ext-net | grep floating_ip_address | awk '{print $4}')
#openstack server add floating ip $vm1 $fip

openstack server list | grep $name
openstack router list | grep $name


