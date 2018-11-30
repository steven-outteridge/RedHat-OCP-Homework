RedHat-OCP-HomeWork Assignment  
Course - 12th - 16th November 2018  
Lecturer - jindrich.kana@elostech.cz  
Deploying Enginer - soutteridge@crossvale.com  
GitRepo -  "git clone https://github.com/steven-outteridge/RedHat-OCP-Homework"  


Pre-requisits
------------
This install is designed to be deployed in the Red Hat Opentlc homework enviroment.  
The install will run from a Bastion host with the OCP ID of system:admin  
After cloning the repo the working directory is /root/RedHat-OCP-Homework  

Overview and quick install  
--------------------------
The cluster install is to be cloned from https://github.com/steven-outteridge/RedHat-OCP-Homework.git.  
It will create an ansible structure under RedHat-OCP-Homework with hosts group_vars config files, templates and scripts.  
Assuming clone from /root as root, the cluster can then be installed using the command:  

/root/RedHat-OCP-Homework/installcluster.sh  

Logs  
----  
As all deployments are managed by Ansible, so logging is enabled in ansible.cfg to point to /var/log/ansible.log.  


Pre Configured host file and group_vars:  
----------------------------------------  
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
playbooks/1.preinstall-local-chks.yml  
playbooks/2.preinstall-chks.yml  

Changes and GUID in configured hosts file to the correct host name variable  
Checks that the bastion host has the latest "atomic-openshift-clients" & "openshift-ansible" packages install  
All nodes have latest docker installed and running  
The NFS node defined in hosts is exporting /srv/nfs with correct permissions and restarts the service  

Installs the cluster:  
/usr/share/ansible/openshift-ansible/playbooks/prerequisites.yml  
/usr/share/ansible/openshift-ansible/playbooks/deploy_cluster.yml  

Post Install:  
playbooks/3.postinstall-chks.yml  
playbooks/4.createpvs.yml  

Import /root/.kube/config to bastion to allow ansibler to manage OCP objects locally  
Create persistent volume files from template for 2 types of storage,  "5G Recycle ReadWriteOnce" & "10G retain ReadWriteMany" then create the persistent volumes on the cluster  

Cluster Test:  
5.create-test-app.yml  

Run up a test project "Smoke Test" and install a DB with persistent storage.  

CI/CD Work FLow:  
playbooks/6.pipeline-install.yml  

Create Jenkins Project and install Jenkins  
Create Build Dev Test and Prod Projects  
Give jenkins service account edit permission on pipeline projects  
Install App into build  
Allow service accounts in Dev Test and Prod to pull images from build  
Create apptags for projects  
Install the apps in the projects  
Expose the services  
Create the pipeline from template into the build project  
Start the pipeline build  

HPA:  
On the Production project created in the CI/CD deployment  
-create a limit range  
-auto scale to 80% CPU threshold and maximum of 10 pods  
-rollout latest deployment  
e.g.  
   NAME                  REFERENCE                          TARGETS    MINPODS   MAXPODS   REPLICAS   AGE  
   hpa/openshift-tasks   DeploymentConfig/openshift-tasks   0% / 80%   1         10        2          2d  
   

Multitenancy:  
playbooks/7.multitenancy.yml  

Create a default project template with limits - /root/RedHat-OCP-Homework/files/basic-template.yaml  
Load template (create)  
Change Template config in master-config.yml to point at new template,  
Restart master-api  
Two clients are sharing a cluster so need isolated projects, alpha and beta with 2 users in each and a common system account for all other workloads.  
Dedicate a node for each Client by labeling 2 compute nodes "client=alpha" & "client=beta"  
Create 2 isolated projects "alpha" & "beta" with node selector "client=alpha" & "client=beta"  
Create 2 users for each project using htpasswd (needs to be done on all masters and atomic-openshift-api)  
Give each pair of users admin access to their respective projects  
Note1! The users can be created using templates called from a script, example below:  

$/root/RedHat-OCP-Homework/scripts/add-user.sh -u Fred -c alpha  

user "Fred" created  

$oc get user/Fred -o yaml  

apiVersion: user.openshift.io/v1  
groups: null  
identities:  
- htpasswd_auth:Fred  
kind: User  
metadata:  
  creationTimestamp: 2018-11-24T12:03:49Z  
  labels:  
    client: alpha  
  name: Fred  
  resourceVersion: "24895"  
  selfLink: /apis/user.openshift.io/v1/users/Fred  
  uid: 008d3f3c-efe1-11e8-b4d4-12c2561ad8aa  

Note2!   
The new template can be appied to the projects:  

$ oc process -f /root/RedHat-OCP-Homework/files/basic-template.yaml -p PROJECT_NAME=alpha -p PROJECT_ADMIN_USER=amy -p PROJECT_REQUESTING_USER=amy -n alpha| oc create -f -  
$ oc get limits  
NAME           AGE  
alpha-limits   12s  
