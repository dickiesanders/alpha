#!/bin/bash

###############################################################################
# create Jenkins job to create the cluster
# Replace the following variables
SERVER=a7653fd7ded834eaa9ac8c874ad748a3-1792366249.us-east-2.elb.amazonaws.com:80
USER=admin
PW=110d49a3cacccae1663b33ed682d78ebbe

# other static variables
CONFIG_FILE=jenkins-job-config.xml
JOB_NAME=alpha

# File where web session cookie is saved, retrieve crumb, and create the new jenkins job
COOKIEJAR="$(mktemp)"
CRUMB=$(curl -u "$USER:$PW" --cookie-jar "$COOKIEJAR" "$SERVER/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,%22:%22,//crumb)")

# install new job
curl -X POST -u "$USER:$PW" --cookie "$COOKIEJAR" -H "$CRUMB" "$SERVER"/createItem?name=$JOB_NAME --data-binary @$CONFIG_FILE -H "Content-Type:application/xml"

# Check that the project was created - should return exists
curl -X GET -u "$USER:$PW" --cookie "$COOKIEJAR" -H "$CRUMB" "$SERVER"/checkJobName?value="$JOB_NAME"

echo
