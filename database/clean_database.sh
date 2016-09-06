#!/bin/bash
if [ -z "$DB_PASS" ]; then
    echo "Sorry!! Need to run 'source passwordlist'"
    echo "Auto source passwordlist"
    source ../passwordlist
fi

echo "Drop database every service"
echo "Service:"
echo "keystone glance nova_api nova neutron cinder manila heat aodh trove"

read -p "Are you Sure to delete all database? [y/n]" prompt

if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]; then
    dbs="keystone glance nova_api nova neutron cinder manila heat aodh trove"
    for d in $dbs; do  mysql -uroot -p$DB_PASS -e "DROP DATABASE $d" ; done

    services="keystone glance nova nova_api neutron cinder manila heat aodh trove"
    for s in $services; do  mysql -uroot -p$DB_PASS -e "DROP USER  '$s'@'%'" ; done
    for s in $services; do  mysql -uroot -p$DB_PASS -e "DROP USER  '$s'@'localhost'" ; done
    for s in $services; do  mysql -uroot -p$DB_PASS -e "DROP USER  '$s'@'controller.example.com'" ; done
else
    exit 0
fi




