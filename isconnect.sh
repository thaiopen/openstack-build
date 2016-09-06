#!/bin/bash
node="controller network compute1 compute2 block1 object1 object2 share1 share2"
for n in $node; do
  if ping -c 1 $n  &> /dev/null
  then
     echo "Success test ping from controller to $n "
  else
     echo "Fail test ping from controller to $n , Please Fix it"
  fi
done
