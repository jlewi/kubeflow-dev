#!/bin/bash
# Don't fail on error because some commands will fail if the resources were already deleted.

set -x 
.  env-kubeflow-jlewi.sh

VERSION=$1

if [ -z ${VERSION} ]; then
	echo "usage create_deployment.sh <version>"
	exit 1
fi	

VERSION_NAME=${VERSION//./-}

DEPLOYMENT_NAME=${DEPLOYMENT_NAME}-${VERSION_NAME}

gcloud deployment-manager --project=${PROJECT} deployments delete \
	${DEPLOYMENT_NAME} \
	--quiet

RESULT=$?

if [ ${RESULT} -ne 0 ]; then
	echo deleting the deployment did not work retry with abandon
	gcloud deployment-manager --project=${PROJECT} deployments delete \
	${DEPLOYMENT_NAME} \
	--quiet \
	--delete-policy=abandon

fi

# Ensure resources are deleted.

gcloud --project=${PROJECT} container clusters delete --zone=${ZONE} \
	${DEPLOYMENT_NAME} --quiet

# Delete service accounts and all role bindings for the service accounts
declare -a accounts=("vm" "admin" "user")

# ow loop through the above array
for suffix in "${accounts[@]}";
do   
   # Delete all role bindings.
   SA=${DEPLOYMENT_NAME}-${suffix}@${PROJECT}.iam.gserviceaccount.com
   python delete_role_bindings.py --project=${PROJECT} --service_account=${SA}
   gcloud --project=${PROJECT} iam service-accounts delete \
	${SA} \
	--quiet		
done

# TODO(jlewi): Should we cleanup ingress , loadbalancer, etc...?