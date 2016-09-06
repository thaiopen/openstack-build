#!/bin/bash
unset OS_TOKEN OS_URL
echo "Verify admin user on controller:35357 with pass $ADMIN_PASS"
openstack --os-auth-url http://controller:35357/v3 --os-project-domain-name default --os-user-domain-name default --os-project-name admin --os-username admin token issue

echo "Verify demo user on controller:5000 with pass $DEMO_PASS"
openstack --os-auth-url http://controller:5000/v3 --os-project-domain-name default --os-user-domain-name default --os-project-name demo --os-username demo token issue

