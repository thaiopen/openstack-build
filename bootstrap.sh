#!/bin/bash -x

sudo setenforce 0
sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo systemctl restart sshd

HOST=$(cat << HOST
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
10.0.0.11  controller.example.com  controller
10.0.0.21  network.example.com  network
10.0.0.31  compute1.example.com compute1
10.0.0.32  compute2.example.com  compute2
10.0.0.41  block1.example.com  block1
10.0.0.51  object1.example.com  object1
10.0.0.52  object2.example.com  object2
10.0.0.61  share1.example.com  share1
10.0.0.62  share2.example.com  share2
HOST
)

sudo echo "$HOST" > /etc/hosts
sudo echo "nameserver 8.8.8.8" > /etc/resolv.conf 


#network service
sudo systemctl start network
sudo systemctl enable network
sudo systemctl disable NetworkManager
sudo systemctl stop NetworkManager

#ntp time server
sudo yum install chrony -y
if [ -f /etc/chrony.conf ];then
    if [ $(hostname -s) = "controller" ]; then
        sudo sed -i.orig '3,6d' /etc/chrony.conf
        sudo sed -i '3i server 1.th.pool.ntp.org iburst' /etc/chrony.conf
        sudo sed -i '4i server 0.asia.pool.ntp.org iburst' /etc/chrony.conf
        sudo sed -i '5i server 2.asia.pool.ntp.org iburst' /etc/chrony.conf
    else
        sudo sed -i.orig '3,6d' /etc/chrony.conf
        sudo sed -i.bak '3i server 10.0.0.11 iburst' /etc/chrony.conf
    fi
fi
sudo systemctl restart chronyd

#repo
sudo yum install -y centos-release-openstack-mitaka
sudo yum install -y python-openstackclient
sudo yum install -y openstack-selinux
sudo yum install -y openstack-utils
sudo yum install -y wget
sudo yum upgrade -y


if [ $(hostname -s) = "controller" ]; then
    #prerequisites
    sudo yum install -y mariadb mariadb-server python2-PyMySQL
    #mongodb
    sudo yum install -y mongodb-server mongodb
    #message
    sudo yum install -y rabbitmq-server
    #memcache
    sudo yum install -y memcached python-memcached
    #keystone
    sudo yum install -y openstack-keystone httpd mod_wsgi
    #glance
    sudo yum install -y openstack-glance
    #compute
    sudo yum install -y openstack-nova-api openstack-nova-conductor \
    openstack-nova-console openstack-nova-novncproxy \
    openstack-nova-scheduler
    #neutron
    sudo yum install -y openstack-neutron openstack-neutron-ml2 \
    openstack-neutron-linuxbridge ebtables
    #dashboard
    sudo yum install -y openstack-dashboard
    #cinder
    sudo yum -y install openstack-cinder
    #manila
    sudo yum install -y openstack-manila python-manilaclient
    #swift proxy
    sudo yum install -y openstack-swift-proxy python-swiftclient \
    python-keystoneclient python-keystonemiddleware memcached
    #heat
    sudo yum install -y openstack-heat-api openstack-heat-api-cfn \
    openstack-heat-engine
    #ceilometer
    sudo yum install -y openstack-ceilometer-api openstack-ceilometer-collector \
    openstack-ceilometer-notification openstack-ceilometer-central \
    python-ceilometerclient
    #aodh alarm service
    sudo yum install -y openstack-aodh-api openstack-aodh-evaluator openstack-aodh-notifier \
    openstack-aodh-listener openstack-aodh-expirer python-ceilometerclient
    #trove
    sudo yum install -y openstack-trove python-troveclient

fi

if [ $(hostname -s) = "network" ]; then
    #neutron network node
    sudo yum install -y openstack-neutron openstack-neutron-ml2 \
    openstack-neutron-linuxbridge ebtables
fi


if [ $(hostname -s) = "compute1" ]; then
    #compute node
    sudo yum install -y openstack-nova-compute
    #neutron
    sudo yum install -y openstack-neutron-linuxbridge ebtables ipset
    #ceilometer
    sudo yum install -y openstack-ceilometer-compute python-ceilometerclient python-pecan

fi
if [ $(hostname -s) = "compute2" ]; then
    #compute node
    sudo yum install -y openstack-nova-compute
    sudo yum install -y openstack-neutron-linuxbridge ebtables ipset
    #ceilometer
    sudo yum install -y openstack-ceilometer-compute python-ceilometerclient python-pecan


fi

if [ $(hostname -s) = "block1" ]; then
    #cinder storage node
    sudo yum install -y lvm2
    sudo yum install -y openstack-cinder targetcli    
fi

if [ $(hostname -s) = "object1" ]; then
    #object swift
    sudo yum install -y xfsprogs rsync
    #object 
    sudo yum install -y openstack-swift-account openstack-swift-container openstack-swift-object
    #cilometer
    sudo yum install -y python-ceilometermiddleware

fi
if [ $(hostname -s) = "object2" ]; then
    #object swift
    sudo yum install -y xfsprogs rsync
    #object 
    sudo yum install -y openstack-swift-account openstack-swift-container openstack-swift-object
    #cilometer
    sudo yum install -y python-ceilometermiddleware

fi

if [ $(hostname -s) = "share1" ]; then
   #manila nfs
   sudo yum install -y openstack-manila-share python2-PyMySQL
   sudo yum install -y lvm2 nfs-utils nfs4-acl-tools portmap
   #neutron component
   sudo yum install -y openstack-neutron openstack-neutron-linuxbridge ebtables
fi

if [ $(hostname -s) = "share2" ]; then
   #manila
   sudo yum install -y openstack-manila-share python2-PyMySQL
   sudo yum install -y lvm2 nfs-utils nfs4-acl-tools portmap
   #neutron component
   sudo yum install -y openstack-neutron openstack-neutron-linuxbridge ebtables
fi


