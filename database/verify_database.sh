#!/bin/bash
echo "Show database"
mysql -uroot -p$DB_PASS -e "show databases;"
echo "Show user"
mysql -uroot -p$DB_PASS -e "SELECT User,host from mysql.user;"

