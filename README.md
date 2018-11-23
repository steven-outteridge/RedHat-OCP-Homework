iRedHat-OCP-HomeWork Assignment
Course - 12th - 16th November 2018
Lecturer - jindrich.kana@elostech.cz
Deploying Enginer - soutteridge@crossvale.com


Overview and quick install
--------------------------
This install is designed to be applied to the Red Hat Opentlc homework enviroment.
The cluster install can be cloned from https://github.com/steven-outteridge/RedHat-OCP-Homework.git.
It will create an ansible structure under RedHat-OCP-Homework with hosts group_vars config files, templates and scripts.
Assuming clone from /root as root the cluster can then be installed using the command:

/root/RedHat-OCP-Homework/installcluster.sh

Logs
----
As all deployments are managed by Ansible, so logging is enabled in ansible.cfg to point to /var/log/ansible.log\


Pre Configured host file:
-------------------------
Host file and host_group-OSEv3 have pre-configured cluster variables:
   Host File:
   Three Masters - (HA requirement)
   Three etcd nodes - (HA requirment)
   Cluster Variables:
   master console definition - (Basic Requirement)
   enabling registry with 20G of persistent NFS storage (Basic Requirement)
   Web proxy that maps URLs and paths into OpenShift services allowing external traffic into cluster.
   configure 2 replicated router pods on infra nodes - label 'env':'infra' (Basic Env and HA Requirement)
   High availabe access to master through loadbalancer (HA requirement)
      openshift_master_cluster_public_hostname
   External access to apps through load balancer (HA Requirment)
      openshift_master_default_subdomain
   Net work Policy set to redhat/openshift-ovs-multitenant to isolate by default (Env Config)
      os_sdn_network_plugin_name
   enable elk logging with with 10G of persistent storage on infra nodes (Env Config)
   enable heapster metrics with hawkcular frontend and cassandra db with 10G of persistent storage(Env Config)
   enable Service Catalogue/ Template Service Broker and Ansible Service Broker(Env Config)
   
   
   
Deploymnent Tasks
-----------------
The ansible master.yml script calls a number of playbooks that peform the following tasks:

Preinstall checks:

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

CI/CD Work FLow:
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
e.g.
   NAME                  REFERENCE                          TARGETS    MINPODS   MAXPODS   REPLICAS   AGE
   hpa/openshift-tasks   DeploymentConfig/openshift-tasks   0% / 80%   1         10        2          2d
   

Multitenancy:
Create a default project tmeplate with limits - /root/RedHat-OCP-Homework/files/basic-template.yaml
Load template (create)
Change Template config in master-config.yml to point at new template,
Restart master-api
Two clients are sharing a cluster so need isolated projects, alpha and beta with 2 users in each and a common system account for all other workloads.
1. Dedicate a node for each Client by labeling 2 compute nodes "client=alpha" & "client=beta"
2. Create 2 isolated projects "alpha" & "beta" with node selector "client=alpha" & "client=beta"
Create 2 users for each project using htpasswd (needs to be done on all masters and atomic-openshift-api)
Give each pait of users admin access to their respective projects



