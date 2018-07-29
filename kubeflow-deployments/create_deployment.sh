#!/bin/bash
# A script to facilitate redeploying Kubeflow using the latest templates.
#

set -ex
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

PROJECT=$1
# Do not include "v" in version"
VERSION=$2
DEPLOYMENT_NAME=$3
DEPLOY=$4

if [ -z ${VERSION} ]; then
	echo "usage create_deployment.sh <version>"
	exit 1
fi	

if [ -z ${DEPLOY} ]; then
	DEPLOY=true
fi

VERSION_NAME=${KUBEFLOW_VERSION//./-}

cd ${DIR}

DEPLOY_DIR=${DIR}/${DEPLOYMENT_NAME}

if [ -d "${DEPLOY_DIR}" ]; then
	echo "${DEPLOY_DIR}" already exists
	exit 1
fi	


mkdir -p ${DEPLOY_DIR}

. ~/secrets/jlewi-kubeflow-endpoints-oauth.sh

if [ "${KUBEFLOW_VERSION}" == "local" ]; then
	export KUBEFLOW_REPO=~/git_kubeflow
	rm -rf ./scripts
	cp -r ${KUBEFLOW_REPO}/scripts .${DEPLOY_DIR}/
else
	export _KUBEFLOW_REPO=$(mktemp -d /tmp/tmp.kubeflow-${VERSION_NAME}-XXXX)
fi	

# create_k8s_secrets
# Delete any of the previous service account keys
rm -f *iam.gserviceaccount.com.json

SETUP_PROJECT=${SETUP_PROJECT:false}

# Output the environment variables
cat > ${DEPLOY_DIR}/env.sh << EOF
export PROJECT=${PROJECT}
export KUBEFLOW_VERSION=${VERSION}
export KUBEFLOW_DM_DIR=${DEPLOY_DIR}/dm-configs
export KUBEFLOW_KS_DIR=${DEPLOY_DIR}/ks-app
export DEPLOYMENT_NAME=${DEPLOYMENT_NAME}
EOF

. ${DEPLOY_DIR}/env.sh

if [ "${VERSION}" == "local" ]; then
	cd ${DEPLOY_DIR}/scripts/gke
	./deploy.sh
else
	curl -o ${DEPLOY_DIR}/deploy.sh https://raw.githubusercontent.com/kubeflow/kubeflow/v${KUBEFLOW_VERSION}/scripts/gke/deploy.sh 
    cd ${DEPLOY_DIR}
    chmod a+x deploy.sh
    ./deploy.sh
fi

if ${DEPLOY}; then
	gcloud --project=${PROJECT} container clusters get-credentials --zone=${ZONE} ${DEPLOYMENT_NAME}
	~/git_kubeflow-dev/create_context.sh ${DEPLOYMENT_NAME} kubeflow
fi