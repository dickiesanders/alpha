# Alpha repo - the newly inflated account transit point

## Create the newly inflated account transit point Jenkins Job
- jenkins-job-app-inflation-transit-point.sh - shell script to create the transit point jenkins job
- jenkins-job-config.xml - the configuration file for the above script

## Normal operating files, once the job is created
- Jenkinsfile - the Jenkins job definition
- ParameterPath.csv - newly inflated accounts will be added to this file, then checked in
- run.sh - shell script to create new Application Jenkins Controller
- new-jenkins-chart-values.yaml - Helm values to use, when launching the new Application Jenkins Controller
- **MISSING** - the xml file defining the Jenkins Job in the new Application Jenkins Controller that will create the K8s cluster

## Note about Jenkins creating other Jenkins Pods
The main jenkins controller pod that will create other jenkins controller pods will need to have its service role changed.
 1059  kubectl get sa -A
 1060  kubectl get sa -n jenkins
 1061  kubectl get clusterrolebinding -A
 1062  kubectl get clusterrolebinding transitpoint-jenkins -o yaml
 1064  kubectl get rolebinding -A
 1065  kubectl get role -n jenkins transitpoint-jenkins-schedule-agents -o yaml
 1066  kubectl get role -n jenkins transitpoint-jenkins-schedule-agents -o yaml > transitpoint-jenkins-schedule-agents.yaml
 1068  kubectl edit role -n jenkins transitpoint-jenkins-schedule-agents
>https://www.magalix.com/blog/kubernetes-rbac-101 
