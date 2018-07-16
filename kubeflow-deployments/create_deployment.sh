#!/bin/bash
# A script to facilitate redeploying Kubeflow using the latest templates.
#

set -ex
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

VERSION=$1

if [ -z ${VERSION} ]; then
	echo "usage create_deployment.sh <version>"
	exit 1
fi	

VERSION_NAME=${VERSION//./-}

cd ${DIR}

# We need to copy the source to a directory otherwise it will try to check it out via 
# an HTTP link which isn't what we want since we want to try out our source

# Source environment variables containing client id and secret
.  env-kubeflow-jlewi.sh
DEPLOYMENT_NAME=${DEPLOYMENT_NAME}-${VERSION_NAME}
. ~/secrets/jlewi-kubeflow-endpoints-oauth.sh

if [ "${VERSION}" == "local" ]; then
	export KUBEFLOW_REPO=~/git_kubeflow
	rm -rf ./scripts
	cp -r ${KUBEFLOW_REPO}/scripts ./scripts
else
	export _KUBEFLOW_REPO=$(mktemp -d /tmp/tmp.kubeflow-${VERSION_NAME}-XXXX)
fi	

export KUBEFLOW_KS_DIR=${DIR}/${DEPLOYMENT_NAME}-app
rm -rf ${KUBEFLOW_KS_DIR}

# create_k8s_secrets
# Delete any of the previous service account keys
rm -f *iam.gserviceaccount.com.json

export SETUP_PROJECT=false

if [ "${VERSION}" == "local" ]; then
	cd ${DIR}/scripts/gke
	./deploy.sh
else
	curl https://raw.githubusercontent.com/kubeflow/kubeflow/${VERSION}/scripts/gke/deploy.sh | bash
fi

gcloud --project=${PROJECT} container clusters get-credentials --zone=${ZONE} ${DEPLOYMENT_NAME}
~/git_kubeflow-dev/create_context.sh ${DEPLOYMENT_NAME} kubeflow
