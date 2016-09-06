#!/bin/bash
mv /etc/openstack-dashboard/local_settings /etc/openstack-dashboard/local_settings.backup
if [ -f "local_settings" ]; then
    echo "copy local_settings /etc/openstack-dashboard/local_settings"
    cp local_settings /etc/openstack-dashboard/local_settings
fi
systemctl restart httpd.service memcached.service

echo "login to 10.0.0.11/dashboard"
