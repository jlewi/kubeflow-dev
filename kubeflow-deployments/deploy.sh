#!/bin/bash
# A script to facilitate redeploying Kubeflow using the latest templates.
#

set -ex
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd ${DIR}

cp -f ~/git_kubeflow/docs/gke/configs/cluster-kubeflow.yaml  ./
cp -f ~/git_kubeflow/docs/gke/configs/cluster.jinja  ./

# Source environment variables containing client id and secret
.  env-kubeflow-jlewi.sh
. ~/secrets/jlewi-kubeflow-endpoints-oauth.sh

python modify_yaml.py

gcloud deployment-manager --project=${PROJECT} deployments create ${DEPLOYMENT_NAME} --config=${CONFIG_FILE}
   
gcloud --project=${PROJECT} container clusters get-credentials --zone=${ZONE} ${DEPLOYMENT_NAME}

# create_k8s_secrets
# Delete any of the previous service account keys
rm *iam.gserviceaccount.com.json
~/git_kubeflow/docs/gke/create_k8s_secrets.sh 
# Create oauth secrets
NAMESPACE=kubeflow
kubectl create secret -n ${NAMESPACE} generic kubeflow-oauth --from-literal=CLIENT_ID=${CLIENT_ID} --from-literal=CLIENT_SECRET=${CLIENT_SECRET}

../create_context.sh jlewi-kubeflow ${NAMESPACE}