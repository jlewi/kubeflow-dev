#!/bin/bash
set -ex
JOB_NAME="kfctl-test"
JOB_TYPE=presubmit
#BUILD_NUMBER=$(uuidgen)
#BUILD_NUMBER=${BUILD_NUMBER:0:4}
BUILD_NUMBER=$(date +%m%d-%H%M%S)
REPO_OWNER=kubeflow
REPO_NAME=kubeflow
ENV=kubeflow-testing
DATE=`date +%Y%m%d`
NAMESPACE=kubeflow-test-infra
PULL_NUMBER=1342
# Don't set PULL_PULL_SHA if you want to pull the head of the PR.
# PULL_PULL_SHA=0bc73dc

PROW_VAR="JOB_NAME=${JOB_NAME},JOB_TYPE=${JOB_TYPE},REPO_NAME=${REPO_NAME}"
PROW_VAR="${PROW_VAR},REPO_OWNER=${REPO_OWNER},BUILD_NUMBER=${BUILD_NUMBER}" 
WORKFLOW=kfctl_test

if [ "${JOB_TYPE}" == "presubmit" ]; then
	PROW_VAR="${PROW_VAR},PULL_NUMBER=${PULL_NUMBER}"
	if [ ! -z "${PULL_PULL_SHA}" ]; then
		PROW_VAR="${PROW_VAR},PULL_PULL_SHA=${PULL_PULL_SHA}"
	fi
	VERSION_TAG="v${DATE}-pr${PULL_NUMBER}-${PULL_PULL_SHA}-${BUILD_NUMBER}"
fi

pushd .
cd ~/git_kubeflow/testing/workflows
NAME="${USER}-${JOB_NAME}-${PULL_NUMBER}-${BUILD_NUMBER}"
ks param set --env=${ENV} ${WORKFLOW} namespace "${NAMESPACE}"
ks param set --env=${ENV} ${WORKFLOW} name ${NAME}
ks param set --env=${ENV} ${WORKFLOW} prow_env "${PROW_VAR}"

# LEAVE THE CLUSTER UP 
ks param set --env=${ENV} ${WORKFLOW} deleteCluster "true"

ks apply ${ENV} -c ${WORKFLOW}
popd 

kubectl get wf -o yaml ${NAME}
echo WORKFLOW=${NAME}