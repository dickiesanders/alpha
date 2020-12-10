#!/bin/bash

pod_name=`tail -n 1 ParameterPath.csv | cut -d ',' -f 1`; echo $pod_name
aws eks --region us-east-2 update-kubeconfig --name first
chmod 700 ~/.kube/config
helm repo add jenkins https://charts.jenkins.io
helm repo update

echo "helm install $pod_name jenkins/jenkins -f values.yaml --namespace jenkins"
