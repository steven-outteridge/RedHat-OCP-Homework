RedHat-OCP-HomeWork Assignment
Course - 12th - 16th November 2018
Lecturer - jindrich.kana@elostech.cz


Overview and quick install
--------------------------
This install is designed to be applied to the Red Hat Opentlc homework enviroment.
The cluster install can be cloned from https://github.com/steven-outteridge/RedHat-OCP-Homework.git
It will create an ansible structure under RedHat-OCP-Homework with config files, templates and scripts.
The cluster can then be installed using the command:

/root/RedHat-OCP-Homework/installcluster.sh

The script calls a numbe of playbooks that peform the following:

Preinstall checks:
Changes and GUID in hosts file to the correct hoist name variable
Checks that the bastion host has the latest "atomic-openshift-clients" & "openshift-ansible" packages install
All nodes have latest docker installed and running
The NFS server defined in hosts is exporting /srv/nfs


Basic Requirements
------------------
preinstall ansilble scripts
 Confirm atomic-openshift-clients and openshift-ansible are at the acceptble level
 Check docker is installed on master infra and compute nodes
 Create NFS exports 
Configure host file
   Ansible manages the deployment using hosts and OSEv3 vars files to describes the configuration of the OCP cluster. The hosts needs to contain the phyhsical hostnames under the following groups: lb masters etcd nodes and nfs also the infra nodes need the label 'env':'infra'
   OSEv3 variable.  The deployed services are configure using cluster variables that can live in the host inventory file or be moved out to a yaml group_var file for convenince. Basic requiremnt configurations include,
   master console to port 443
   enabling registry with 20G of NFS storage
   configure 2 replicated router pods on infra nodes
   
Once the pre install checks are complete the install initiates using the host configurations. 

Post Install 50 PV's of different sizes and types a automatically created:
25 x 10G retain ReadWriteMany
25 x 5G Recycle ReadWriteOnce

Install test app nodejs-mongo-persistent to test deployment is OK

HA Requirements
---------------


Router
Web proxy that maps URLs and paths into OpenShift services allowing external traffic into cluster.
