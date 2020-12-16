#!/bin/bash

  export SERVICE_IP=$(kubectl get svc --namespace default jankins-jenkins \
    --template "{{ range (index .status.loadBalancer.ingress 0) }}{{ . }}{{ end }}"); echo http://$SERVICE_IP/login
    
  export SERVICE_SECRET=$(kubectl exec --namespace default -it svc/jankins-jenkins -c jenkins -- /bin/cat /run/secrets/chart-admin-password)
  echo $SERVICE_SECRET; echo

  ###############################################################################
  # create Jenkins job to create the cluster
  # Replace the following variables
  SERVER=$SERVICE_IP:80
  USER=admin
  PW=$SERVICE_SECRET

  # other static variables
  CONFIG_FILE=jenkins-job-config.xml
  JOB_NAME=newly_inflated_account_transit_point

  # File where web session cookie is saved, retrieve crumb, and create the new jenkins job
  COOKIEJAR="$(mktemp)"
  CRUMB=$(curl -u "$USER:$PW" --cookie-jar "$COOKIEJAR" "$SERVER/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,%22:%22,//crumb)")

  # install new job
  curl -X POST -u "$USER:$PW" --cookie "$COOKIEJAR" -H "$CRUMB" "$SERVER"/createItem?name=$JOB_NAME --data-binary @$CONFIG_FILE -H "Content-Type:application/xml"

  # Check that the project was created - should return exists
  curl -X GET -u "$USER:$PW" --cookie "$COOKIEJAR" -H "$CRUMB" "$SERVER"/checkJobName?value="$JOB_NAME"

  echo
