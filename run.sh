#!/bin/bash

# create new Application Jenkins Controller
pod_name=`tail -n 1 ParameterPath.csv | cut -d ',' -f 1`; echo $pod_name
aws eks --region us-east-2 update-kubeconfig --name first
chmod 700 ~/.kube/config
helm repo add jenkins https://charts.jenkins.io
helm repo update

echo "helm install $pod_name jenkins/jenkins -f values.yaml --namespace jenkins"

# create Jenkins job to create the cluster
### get current config
curl -X GET http://developer:developer@localhost:8080/job/test/config.xml -o mylocalconfig.xml

### update and return to jenkins
curl -X POST http://developer:developer@localhost:8080/job/test/config.xml --data-binary "@mymodifiedlocalconfig.xml"

# Jenkins configuration file, that can be included in the filesystem of the container

# update Application Infra Repo

### replace app_infra_repo with value in Parameter Store
app_infra_repo='git@github.com:mi5guided/beta.git'

git clone $app_infra_repo

cd `echo $app_infra_repo | cut -d '/' -f 2 | cut -d '.' -f 1`
### or, if parsing the git repo url string too hard, use below
# cd `ls -t -1 | head -n 1`

### set identity of 
cat << 'NEWPARAM' >> .git/config
[user]
  email = accounthandoff@example.com
  name = accthandoff automation
NEWPARAM

git commit --allow-empty -m "Trigger Build `date`"
git push