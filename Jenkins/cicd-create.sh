#!/bin/bash
oc new-project cicd-dev
oc new-app jenkins-persistent -p ENABLE_OAUTH=false -e JENKINS_PASSWORD=openshiftpipelines -n cicd-dev
sleep 10

oc new-project tasks-build
oc new-project tasks-dev
oc new-project tasks-test
oc new-project tasks-prod
sleep 10

oc policy add-role-to-user edit system:serviceaccount:cicd-dev:jenkins -n cicd-dev
oc policy add-role-to-user edit system:serviceaccount:cicd-dev:jenkins -n tasks-build
oc policy add-role-to-user edit system:serviceaccount:cicd-dev:jenkins -n tasks-dev
oc policy add-role-to-user edit system:serviceaccount:cicd-dev:jenkins -n tasks-test
oc policy add-role-to-user edit system:serviceaccount:cicd-dev:jenkins -n tasks-prod

oc new-app jboss-eap70-openshift:1.6~https://github.com/OpenShiftDemos/openshift-tasks -n tasks-build
sleep 120

oc policy add-role-to-group system:image-puller system:serviceaccounts:tasks-prod -n tasks-build
oc policy add-role-to-group system:image-puller system:serviceaccounts:tasks-test -n tasks-build
oc policy add-role-to-group system:image-puller system:serviceaccounts:tasks-dev -n tasks-build

oc tag openshift-tasks:latest openshift-tasks:devready -n tasks-build
oc tag openshift-tasks:devready openshift-tasks:testready -n tasks-build
oc tag openshift-tasks:testready openshift-tasks:prodready -n tasks-build

oc new-app tasks-build/openshift-tasks:devready -n tasks-dev
oc new-app tasks-build/openshift-tasks:testready -n tasks-test
oc new-app tasks-build/openshift-tasks:prodready -n tasks-prod
sleep 20
oc expose svc openshift-tasks -n tasks-build
oc expose svc openshift-tasks -n tasks-dev
oc expose svc openshift-tasks -n tasks-test
oc expose svc openshift-tasks -n tasks-prod
oc create -f /root/RedHat-OCP-Homework/Jenkins/pipeline.yaml
oc start-build tasks-pipeline

