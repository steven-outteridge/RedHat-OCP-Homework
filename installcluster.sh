#!/bin/bash


echo "get GUID from opentlc and distribute it to the hosts file"

echo "Set the current GUID to generate the inventory"echo "Set the current GUID to generate the inventory"
GUID=`hostname|awk -F. '{print $2}'`
sed -i "s/GUID/$GUID/g" /root/RedHat-OCP-Homework/inventory/hosts


ansible-playbook -i /root/RedHat-OCP-Homework/inventory/hosts /root/RedHat-OCP-Homework/playbooks/master.yml
