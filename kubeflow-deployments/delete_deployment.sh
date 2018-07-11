#!/bin/bash
set -x 
.  env-kubeflow-jlewi.sh


gcloud deployment-manager --project=${PROJECT} deployments delete \
	${DEPLOYMENT_NAME} \
	--quiet

RESULT=$?

set -e

if [ ${RESULT} -ne 0 ]; then
	echo deleting the deployment did not work retry with abandon
	gcloud deployment-manager --project=${PROJECT} deployments delete \
	${DEPLOYMENT_NAME} \
	--quiet \
	--delete-policy=abandon

fi

gcloud --project=${PROJECT} container clusters delete --zone=${ZONE} \
	${DEPLOYMENT_NAME} --quiet

# Delete service accounts
declare -a accounts=("vm" "admin" "user")

# now loop through the above array
for suffix in "${accounts[@]}"
do   
   gcloud --project=${PROJECT} iam service-accounts delete \
	${DEPLOYMENT_NAME}-${suffix}@${PROJECT}.iam.gserviceaccount.com \
	--quiet	
done
