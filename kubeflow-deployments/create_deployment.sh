#!/bin/bash
# A script to facilitate redeploying Kubeflow using the latest templates.
#

set -ex
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd ${DIR}

cp -f ~/git_kubeflow/docs/gke/configs/cluster-kubeflow.yaml  ./
cp -f ~/git_kubeflow/docs/gke/configs/cluster.jinja  ./
cp -f ~/git_kubeflow/docs/gke/configs/deploy.sh ./deploy.sh

# Source environment variables containing client id and secret
.  env-kubeflow-jlewi.sh
. ~/secrets/jlewi-kubeflow-endpoints-oauth.sh

python modify_yaml.py

# create_k8s_secrets
# Delete any of the previous service account keys
rm *iam.gserviceaccount.com.json

./deploy.sh