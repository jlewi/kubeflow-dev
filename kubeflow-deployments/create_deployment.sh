#!/bin/bash
# A script to facilitate redeploying Kubeflow using the latest templates.
#

set -ex
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export PROJECT=$1
export DEPLOYMENT_NAME=$3
# Tag to checkout
KUBEFLOW_TAG=$2
export KUBEFLOW_CLOUD=gke

usage () {
	echo "create_deployment.sh <PROJECT> <DEPLOYMENT_NAME> <TAG>"
}

if [  -z  "${PROJECT}" ]; then
  usage
  exit 1
fi	

if [ -z  "${DEPLOYMENT_NAME}" ]; then
  usage
  exit 1
fi	

if [ -z  "${KUBEFLOW_TAG}" ]; then
  usage
  exit 1
fi	

mkdir -p ${DEPLOYMENT_NAME}

cd ${DEPLOYMENT_NAME}

if [ -z "${KUBEFLOW_SOURCE}" ]; then  
  curl https://raw.githubusercontent.com/kubeflow/kubeflow/${KUBEFLOW_TAG}/scripts/download.sh | bash
else
  ${KUBEFLOW_SOURCE}/scripts/download.sh
fi

${DIR}/${DEPLOYMENT_NAME}/deploy.sh configure