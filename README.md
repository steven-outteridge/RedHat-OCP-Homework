# RedHat-OCP-HomeWork Assignment
Overview and quick install
The cluster install can be cloned from https://github.com/steven-outteridge/RedHat-OCP-Homework.git
It will create the following ansible structure to assist with install:

RedHat-OCP-Homework
├── ansible.cfg
├── inventory
│   ├── group_vars
│   │   └── OSEv3
│   ├── hosts
├── playbooks
│   ├── 1.preinstall-chks.yml
│   ├── 2.preinstall-local-chks.yml
│   ├── 3.postinstall-chks.yml
│   ├── 4.createpvs.yml
│   ├── master.yml
│   └── templates
│       ├── homework-basic-ha.exports
│       ├── homework-uservols.exports
│       └── pvfile
└── README.md


The cluster can then be installed using the command:

ansible-playbook -i /root/RedHat-OCP-Homework/inventory/hosts /root/RedHat-OCP-Homework/playbooks/master.yml

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
