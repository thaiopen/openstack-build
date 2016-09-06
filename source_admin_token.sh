 #!/bin/bash
 
 if [ -z "$ADMIN_TOKEN" ]; then
     echo "Sorry!! Need to run 'source passwordlist'"
     exit 1
 fi
 
 echo "Environment Varaible"
 echo "ADMIN_TOKEN= $ADMIN_TOKEN"
 export OS_TOKEN=$ADMIN_TOKEN
 export OS_URL=http://controller:35357/v3
 export OS_IDENTITY_API_VERSION=3

