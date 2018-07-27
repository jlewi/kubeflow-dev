#!/bin/bash
# A script to facilitate redeploying Kubeflow using the latest templates.
#

set -ex
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

PROJECT=$1
VERSION=$2
DEPLOYMENT_NAME=$3

if [ -z ${VERSION} ]; then
	echo "usage create_deployment.sh <version>"
	exit 1
fi	

VERSION_NAME=${VERSION//./-}

cd ${DIR}

DEPLOY_DIR=${DIR}/${DEPLOYMENT_NAME}

mkdir -p ${DEPLOY_DIR}

# DEPLOYMENT_NAME=${DEPLOYMENT_NAME}-${VERSION_NAME}

. ~/secrets/jlewi-kubeflow-endpoints-oauth.sh

if [ "${VERSION}" == "local" ]; then
	export KUBEFLOW_REPO=~/git_kubeflow
	rm -rf ./scripts
	cp -r ${KUBEFLOW_REPO}/scripts .${DEPLOY_DIR}/
else
	export _KUBEFLOW_REPO=$(mktemp -d /tmp/tmp.kubeflow-${VERSION_NAME}-XXXX)
fi	

#export KUBEFLOW_KS_DIR=${DEPLOY_DIR}/app
#rm -rf ${KUBEFLOW_KS_DIR}

# create_k8s_secrets
# Delete any of the previous service account keys
rm -f *iam.gserviceaccount.com.json

SETUP_PROJECT=${SETUP_PROJECT:false}

if [ "${VERSION}" == "local" ]; then
	cd ${DEPLOY_DIR}/scripts/gke
	./deploy.sh
else
	curl -o ${DEPLOY_DIR}/deploy.sh https://raw.githubusercontent.com/kubeflow/kubeflow/${VERSION}/scripts/gke/deploy.sh 
    cd ${DEPLOY_DIR}
    chmod a+x deploy.sh
    ./deploy.sh
fi

gcloud --project=${PROJECT} container clusters get-credentials --zone=${ZONE} ${DEPLOYMENT_NAME}
~/git_kubeflow-dev/create_context.sh ${DEPLOYMENT_NAME} kubeflow
