#mysql
#file: /etc/my.cnf.d/openstack.cnf
[mysqld]
bind-address = 10.0.0.11
default-storage-engine = innodb
innodb_file_per_table
max_connections = 4096
collation-server = utf8_general_ci
character-set-server = utf8
sql_mode = NO_ENGINE_SUBSTITUTION

systemctl restart mariadb

#mongodb
openstack-config --set /etc/mongod.conf bind_ip 10.0.0.11
openstack-config --set /etc/mongod.conf smallfiles true

#restart mongodb
systemctl enable mongod.service
systemctl start mongod.service

#message
systemctl enable rabbitmq-server.service
systemctl start rabbitmq-server.service

rabbitmqctl add_user openstack $RABBIT_PASS

#memcache
systemctl enable memcached.service
systemctl start memcached.service

#keystone
#file: /etc/keystone/keystone.conf

openstack-config --set /etc/keystone/keystone.conf DEFAULT admin_token $ADMIN_TOKEN

  /etc/keystone/keystone.conf database connection mysql+pymysql://keystone:$KEYSTONE_DBPASS@controller/keystone

openstack-config --set /etc/keystone/keystone.conf token provider fernet

su -s /bin/sh -c "keystone-manage db_sync" keystone

#http
#file: /etc/httpd/conf/httpd.conf

ServerName controller

vi /etc/httpd/conf.d/wsgi-keystone.conf

systemctl enable httpd.service
systemctl start httpd.service

netstat -tapnu | grep 5000
netstat -tapnu | grep 5000


export OS_TOKEN=$ADMIN_TOKEN
export OS_URL=http://controller:35357/v3
export OS_IDENTITY_API_VERSION=3

openstack service create --name keystone --description "OpenStack Identity" identity
openstack endpoint create --region RegionOne identity public http://controller:5000/v3
openstack endpoint create --region RegionOne identity internal http://controller:5000/v3
openstack endpoint create --region RegionOne identity admin http://controller:35357/v3


#set 1 admin
openstack domain create --description "Default Domain" default
openstack project create --domain default --description "Admin Project" admin
openstack user create --domain default --password-prompt admin
openstack role create admin
openstack role add --project admin --user admin admin

#set 2 service
openstack project create --domain default --description "Service Project" service
openstack project create --domain default --description "Demo Project" demo
openstack user create --domain default --password-prompt demo
openstack role create user
openstack role add --project demo --user demo user


unset OS_TOKEN OS_URL
#request
openstack --os-auth-url http://controller:35357/v3 \
  --os-project-domain-name default --os-user-domain-name default \
  --os-project-name admin --os-username admin token issue

openstack --os-auth-url http://controller:5000/v3 \
  --os-project-domain-name default --os-user-domain-name default \
  --os-project-name demo --os-username demo token issue



vi admin-openrc
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=$ADMIN_PASS
export OS_AUTH_URL=http://controller:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2



#glance
openstack user create --domain default --password-prompt glance
openstack role add --project service --user glance admin
openstack service create --name glance --description "OpenStack Image" image

openstack endpoint create --region RegionOne image public http://controller:9292
openstack endpoint create --region RegionOne image internal http://controller:9292
openstack endpoint create --region RegionOne image admin http://controller:9292

#/etc/glance/glance-api.conf 

 
openstack-config --set  /etc/glance/glance-api.conf database connection mysql+pymysql://glance:$GLANCE_DBPASS@controller/glance

 
openstack-config --set  /etc/glance/glance-api.conf keystone_authtoken auth_uri  http://controller:5000
openstack-config --set  /etc/glance/glance-api.conf keystone_authtoken auth_url  http://controller:35357
openstack-config --set  /etc/glance/glance-api.conf keystone_authtoken openstack-config --set  /etc/glance/glance-api.conf memcached_servers  controller:11211
openstack-config --set  /etc/glance/glance-api.conf keystone_authtoken auth_type  password
openstack-config --set  /etc/glance/glance-api.conf keystone_authtoken project_domain_name  default
openstack-config --set  /etc/glance/glance-api.conf keystone_authtoken user_domain_name  default
openstack-config --set  /etc/glance/glance-api.conf keystone_authtoken project_name  service
openstack-config --set  /etc/glance/glance-api.conf username  glance
openstack-config --set  /etc/glance/glance-api.conf password  $GLANCE_PASS
openstack-config --set  /etc/glance/glance-api.conf paste_deploy  flavor keystone


openstack-config --set  /etc/glance/glance-api.conf glance_store stores  file,http
openstack-config --set  /etc/glance/glance-api.conf glance_store stores default_store  file
openstack-config --set  /etc/glance/glance-api.conf glance_store stores default_store filesystem_store_datadir  /var/lib/glance/images/


openstack-config --set /etc/glance/glance-registry.conf database connection mysql+pymysql://glance:$GLANCE_DBPASS@controller/glance

openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken  auth_uri  http://controller:5000
openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken  auth_url  http://controller:35357
openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken  memcached_servers  controller:11211
openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken  auth_type  password
openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken  project_domain_name  default
openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken  user_domain_name  default
openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken  project_name  service
openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken  username  glance
openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken  password  $GLANCE_PASS
openstack-config --set /etc/glance/glance-registry.conf paste_deploy  flavor  keystone

