#!/bin/bash
if [ -z "$DB_PASS" ]; then
    echo "Sorry!! Need to run 'source passwordlist'"
    echo "Auto source passwordlist"
    source ../passwordlist
fi
mysql -uroot -p$DB_PASS -e "show databases;"
mysql -uroot -p$DB_PASS -e "SELECT User,host from mysql.user;" 

