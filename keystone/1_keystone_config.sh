if [ -z "$ADMIN_TOKEN" ]; then
    echo "Sorry!! Need to run 'source passwordlist'"
    echo "Auto source passwordlist"
    source ../passwordlist
fi

echo "Environment Varaible"
echo "ADMIN_TOKEN= $ADMIN_TOKEN"
echo "KEYSTONE_DBPASS = $KEYSTONE_DBPASS"
read -p "Press enter to continue"
file="/etc/keystone/keystone.conf"
echo "Run openstack-config on file ${file}"
cp $file $file.backup
openstack-config --set ${file} DEFAULT admin_token $ADMIN_TOKEN
openstack-config --set ${file} database connection mysql+pymysql://keystone:$KEYSTONE_DBPASS@controller/keystone
openstack-config --set ${file} token provider fernet 

echo "Verify..."
echo "admin_token=$(openstack-config --get ${file} DEFAULT admin_token)"
echo "connection=$(openstack-config --get ${file} database connection)"
echo "token=$(openstack-config --get ${file} token provider)"

echo "Populate identity service database"
su -s /bin/sh -c "keystone-manage db_sync" keystone > /dev/tty
echo "Initialize Fernet keys"
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone > /dev/tty
