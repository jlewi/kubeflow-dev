#!/bin/bash
# A script to facilitate redeploying Kubeflow using the latest templates.
#

set -ex
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd ${DIR}

# We need to copy the source to a directory otherwise it will try to check it out via 
# an HTTP link which isn't what we want since we want to try out our source
export KUBEFLOW_REPO=${DIR}/kubeflow_source
cp -f ${KUBEFLOW_REPO}/scripts ./scripts

# Source environment variables containing client id and secret
.  env-kubeflow-jlewi.sh
. ~/secrets/jlewi-kubeflow-endpoints-oauth.sh

# create_k8s_secrets
# Delete any of the previous service account keys
rm -f *iam.gserviceaccount.com.json

export SETUP_PROJECT=false
cd ${DIR}/scripts/gke
./deploy.sh

gcloud --project=${PROJECT} container clusters get-credentials --zone=${ZONE} ${DEPLOYMENT_NAME}
~/git_kubeflow-dev/create_context.sh ${DEPLOYMENT_NAME} kubeflow
