#!/bin/bash
# A script to facilitate redeploying Kubeflow using the latest templates.

set -ex
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd ${DIR}

cp -f ~/git_kubeflow/docs/gke/configs/cluster-kubeflow.yaml  ./
cp -f ~/git_kubeflow/docs/gke/configs/cluster.jinja  ./

# Source environment variables containing client id and secret
. ~/secrets/jlewi-kubeflow-endpoints-oauth.sh


jq -r ".metadata.annotations.iaplock=\"$(hostname -s) ${NOW}\"" service.json > service_lock.json