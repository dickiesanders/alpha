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