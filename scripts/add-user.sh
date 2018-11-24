#!/usr/bin/env bash

while getopts u:c: option
do
case "${option}"
in
u) USER=${OPTARG};;
c) CLIENT=${OPTARG};;
esac
done

oc process -f /root/RedHat-OCP-Homework/files/user-template.yaml -p USERNAME=${USER} -p CLIENT=${CLIENT} | oc create -f -
