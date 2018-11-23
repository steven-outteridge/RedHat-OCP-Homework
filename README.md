RedHat-OCP-HomeWork Assignment
Course - 12th - 16th November 2018
Lecturer - jindrich.kana@elostech.cz


Overview and quick install
--------------------------
This install is designed to be applied to the Red Hat Opentlc homework enviroment.
The cluster install can be cloned from https://github.com/steven-outteridge/RedHat-OCP-Homework.git.
It will create an ansible structure under RedHat-OCP-Homework with hosts group_vars config files, templates and scripts.
The cluster can then be installed using the command:

/root/RedHat-OCP-Homework/installcluster.sh

Tasks
-----
Basic Requirements:
Configure host file:
Host file and host_grouip OSEv3 have been pre-configured cluster variables:
   master console to port 443
   enabling registry with 20G of NFS storage
   configure 2 replicated router pods on infra nodes


The ansible script calls a number of playbooks that peform the following tasks:

Preinstall checks:
Ansible manages the deployment using hosts and OSEv3 vars files to describes the configuration of the OCP cluster. The hosts needs to contain the phyhsical hostnames under the following groups:
lb masters
etcd
nodes and nfs also the infra nodes need the label 'env':'infra'
Changes and GUID in configured hosts file to the correct hoist name variable
Checks that the bastion host has the latest "atomic-openshift-clients" & "openshift-ansible" packages install
All nodes have latest docker installed and running
The NFS node defined in hosts is exporting /srv/nfs with correct permissions and restarts the service

Installs the cluster:
/usr/share/ansible/openshift-ansible/playbooks/prerequisites.yml
/usr/share/ansible/openshift-ansible/playbooks/deploy_cluster.yml

Post Install:
Import /root/.kube/config to bastion to allow ansibler to manage OCP objects locally
Create persistent volume files from template for 2 types of storage,  "5G Recycle ReadWriteOnce" & "10G retain ReadWriteMany" then create the persistent volumes on the cluster

Cluster Test:
Run up a test project "Smoke Test" and install a DB with persistent storage.

CI/CD:
Create Jenkins Project and install Jenkins
Create Build Dev Test and Prod Projects
Give jenkins service account edit permission on pipeline projects
Install App into build
Allow service accounts in Dev Test and Prod to pull images from buld
Create apptags for projects
Install the apps iunb the projects
Expose the services
Create the pipeline from template into the build project
Start the pipeline build 

HPA:
On the Production project created in the CI/CD deployment
create a limit range
auto scale to 80% CPU threshold and maximum of 10 pods
rollout latest deployment










HA Requirements
---------------


Router
Web proxy that maps URLs and paths into OpenShift services allowing external traffic into cluster.
