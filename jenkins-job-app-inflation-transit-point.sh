#!/bin/bash
helmname=transitpoint
name_space=jenkins

export SERVICE_IP=$(kubectl get svc --namespace $name_space $helmname-jenkins \
  --template "{{ range (index .status.loadBalancer.ingress 0) }}{{ . }}{{ end }}"); echo http://$SERVICE_IP/login
  
export SERVICE_SECRET=$(kubectl exec --namespace $name_space -it svc/$helmname-jenkins -c jenkins -- /bin/cat /run/secrets/chart-admin-password)
echo $SERVICE_SECRET; echo

###############################################################################
# create Jenkins job to create the cluster
# Replace the following variables
SERVER=$SERVICE_IP:80
USER=admin
PW=$SERVICE_SECRET
PEMID=mi5guidedxx
PEMKEY=$(aws ssm get-parameters --with-decryption --names '/personal/github/key' --query Parameters[0].Value)

# other static variables
CONFIG_FILE=jenkins-pipeline-config.xml
JOB_NAME=new_account_transit_point

# File where web session cookie is saved, retrieve crumb, and create the new jenkins job
COOKIEJAR="$(mktemp)"
CRUMB=$(curl -u "$USER:$PW" --cookie-jar "$COOKIEJAR" "$SERVER/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,%22:%22,//crumb)")

# install git credentials
# curl -X POST -u "$USER:$PW" --cookie "$COOKIEJAR" -H "$CRUMB" "$SERVER"/credentials/store/system/domain/_/createCredentials --data-urlencode "json={\"\": \"0\",\"credentials\": {\"scope\": \"GLOBAL\",\"id\": \"$PEMID\",\"username\": \"$PEMID\",\"password\": \"\",\"privateKeySource\": {\"stapler-class\": \"com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey$DirectEntryPrivateKeySource\",\"privateKey\": \"$PEMKEY\",},\"description\": \"apicredentials\",\"stapler-class\": \"com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey\"}}"

# install new job
curl -X POST -u "$USER:$PW" --cookie "$COOKIEJAR" -H "$CRUMB" "$SERVER"/createItem?name=$JOB_NAME --data-binary @$CONFIG_FILE -H "Content-Type:application/xml"

# Check that the project was created - should return exists
curl -X GET -u "$USER:$PW" --cookie "$COOKIEJAR" -H "$CRUMB" "$SERVER"/checkJobName?value="$JOB_NAME"

echo

