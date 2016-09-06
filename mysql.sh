#!/bin/bash

#set database
openstack-config --set openstack.cnf mysqld bind-address 10.0.0.11 
openstack-config --set openstack.cnf mysqld default-storage-engine innodb
openstack-config --set openstack.cnf mysqld max_connections  4096
openstack-config --set openstack.cnf mysqld collation-server  utf8_general_ci
openstack-config --set openstack.cnf mysqld character-set-server  utf8

#keystone
yum install openstack-keystone httpd mod_wsgi -y
openstack-config --set /etc/keystone/keystone.conf DEFAULT admin_token $ADMIN_TOKEN
openstack-config --set /etc/keystone/keystone.conf database connection mysql+pymysql://keystone:$KEYSTONE_DBPASS@controller/keystone
openstack-config --set /etc/keystone/keystone.conf token provider fernet
su -s /bin/sh -c "keystone-manage db_sync" keystone

# mysql -uroot -p
Enter password: 
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 7
Server version: 10.1.12-MariaDB MariaDB Server

Copyright (c) 2000, 2016, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> FLUSH PRIVILEGES;
MariaDB [(none)]> SELECT User, Host, Password FROM mysql.user;

export OS_TOKEN=$ADMIN_TOKEN
export OS_URL=http://controller:35357/v3
export OS_IDENTITY_API_VERSION=3

vi /etc/httpd/conf.d/wsgi-keystone.conf

Listen 0.0.0.0:5000
Listen 0.0.0.0:35357

openstack service create --name keystone --description "OpenStack Identity" identity

# openstack service create --name keystone --description "OpenStack Identity" identity
+-------------+----------------------------------+
| Field       | Value                            |
+-------------+----------------------------------+
| description | OpenStack Identity               |
| enabled     | True                             |
| id          | 938663f07f3b4c4b92d024250edacc82 |
| name        | keystone                         |
| type        | identity                         |
+-------------+----------------------------------+



 DBConnectionError: (pymysql.err.OperationalError) (2003, "Can't connect to MySQL server on 'controller' ([Errno 111] Connection refused)")

mysql -u root -p$DB_PASS << EOF                                                                
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'controller' IDENTIFIED BY '$KEYSTONE_DBPASS';
EOF




