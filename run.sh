#!/bin/bash

# Prep the environment, including getting name of new account
pod_name=`tail -n 1 ParameterPath.csv | cut -d ',' -f 1`; echo $pod_name
pod_name=newaccountjenkins
name_space=jenkins-newacct

###############################################################################
# create new Application Jenkins Controller
if [ $1 ]; then
  # kubectl delete pod jankins
  helm uninstall $pod_name
else
  aws eks --region us-east-2 update-kubeconfig --name alpha-cluster
  chmod 700 ~/.kube/config

  helm repo add jenkins https://charts.jenkins.io
  helm repo update

  # helm repo add jenkins https://charts.jenkins.io
  helm install $pod_name jenkins/jenkins -f new-jenkins-chart-values.yaml --namespace $name_space --create-namespace
  kubectl get pods -A
  kubectl get services -A

  echo "Waiting for Jenkins to settle in"
  sleep 300

  ###############################################################################
  # get new jenkins pod information
  export SERVICE_IP=$(kubectl get svc --namespace $name_space $pod_name-jenkins \
    --template "{{ range (index .status.loadBalancer.ingress 0) }}{{ . }}{{ end }}"); echo http://$SERVICE_IP/login
    
  export SERVICE_SECRET=$(kubectl exec --namespace $name_space -it svc/$pod_name-jenkins -c jenkins -- /bin/cat /run/secrets/chart-admin-password)
  echo $SERVICE_SECRET; echo

  ###############################################################################
  # create Jenkins job to create the new application K8s cluster
  # Replace the following variables
  SERVER=$SERVICE_IP:80
  USER=admin
  PW=$SERVICE_SECRET
  CONFIG_FILE=new-jenkins-pipeline-config.xml
  JOB_NAME=$pod_name-infrastructure

  # File where web session cookie is saved, retrieve crumb, and create the new jenkins job
  COOKIEJAR="$(mktemp)"
  CRUMB=$(curl -u "$USER:$PW" --cookie-jar "$COOKIEJAR" "$SERVER/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,%22:%22,//crumb)")

  # install plug-ins we need
  curl -X POST -u "$USER:$PW" --cookie "$COOKIEJAR" -H "$CRUMB" -d '<jenkins><install plugin="github@1.32.0" /></jenkins>' --header 'Content-Type: text/xml' "$SERVER/pluginManager/installNecessaryPlugins"
  curl -X POST -u "$USER:$PW" --cookie "$COOKIEJAR" -H "$CRUMB" -d '<jenkins><install plugin="bitbucket@1.1.27" /></jenkins>' --header 'Content-Type: text/xml' "$SERVER/pluginManager/installNecessaryPlugins"

  # install new job
  curl -X POST -u "$USER:$PW" --cookie "$COOKIEJAR" -H "$CRUMB" "$SERVER"/createItem?name=$JOB_NAME --data-binary @$CONFIG_FILE -H "Content-Type:application/xml"

  # Check that the project was created - should return exists
  curl -X GET -u "$USER:$PW" --cookie "$COOKIEJAR" -H "$CRUMB" "$SERVER"/checkJobName?value="$JOB_NAME"


  ###############################################################################
  # update repo, to trigger build of K8s cluster. This may have to be manual..
  ### replace app_infra_repo with value in Parameter Store

  # app_infra_repo='git@github.com:mi5guided/beta.git'
  # git clone $app_infra_repo

  # cd `echo $app_infra_repo | cut -d '/' -f 2 | cut -d '.' -f 1`
  ### or, if parsing the git repo url string too hard, use below
  # cd `ls -t -1 | head -n 1`

  ### set identity of 
  # cat << 'NEWPARAM' >> .git/config
  # [user]
  #   email = accounthandoff@example.com
  #   name = accthandoff automation
  # NEWPARAM

  # git commit --allow-empty -m "Trigger Build `date`"
  # git push
  ###############################################################################
fi
