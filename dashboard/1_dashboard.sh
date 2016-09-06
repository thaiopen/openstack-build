#!/bin/bash
if [ ! -f /etc/openstack-dashboard/local_settings.orig ]; then
   mv /etc/openstack-dashboard/local_settings /etc/openstack-dashboard/local_settings.orig
fi

if [ -f local_settings ]; then
    echo "copy local_settings /etc/openstack-dashboard/local_settings"
    rm -rf /etc/openstack-dashboard/local_settings
    cp local_settings /etc/openstack-dashboard/local_settings
fi
chown root:apache /etc/openstack-dashboard/local_settings
systemctl restart httpd.service memcached.service

echo "login to 10.0.0.11/dashboard"
