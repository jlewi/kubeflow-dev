#!/bin/bash
set -ex
JOB_NAME="mnist-test"
JOB_TYPE=presubmit
#BUILD_NUMBER=$(uuidgen)
#BUILD_NUMBER=${BUILD_NUMBER:0:4}
BUILD_NUMBER=$(date +%m%d-%H%M%S)
REPO_OWNER=kubeflow
REPO_NAME=examples
ENV=test
DATE=`date +%Y%m%d`
NAMESPACE=kubeflow-test-infra
#PULL_NUMBER=449
PULL_NUMBER=479

# Don't set PULL_PULL_SHA if you want to pull the head of the PR.
# PULL_PULL_SHA=0bc73dc

PROW_VAR="JOB_NAME=${JOB_NAME},JOB_TYPE=${JOB_TYPE},REPO_NAME=${REPO_NAME}"
PROW_VAR="${PROW_VAR},REPO_OWNER=${REPO_OWNER},BUILD_NUMBER=${BUILD_NUMBER}" 
PROW_VAR="${PROW_VAR},BUILD_ID=${BUILD_NUMBER}" 
WORKFLOW=mnist

if [ "${JOB_TYPE}" == "presubmit" ]; then
	PROW_VAR="${PROW_VAR},PULL_NUMBER=${PULL_NUMBER}"
	if [ ! -z "${PULL_PULL_SHA}" ]; then
		PROW_VAR="${PROW_VAR},PULL_PULL_SHA=${PULL_PULL_SHA}"
	fi
	VERSION_TAG="v${DATE}-pr${PULL_NUMBER}-${PULL_PULL_SHA}-${BUILD_NUMBER}"
fi

pushd .
cd ~/git_kubeflow-examples/test/workflows
NAME="${USER}-${JOB_NAME}-${PULL_NUMBER}-${BUILD_NUMBER}"
ks param set --env=${ENV} ${WORKFLOW} namespace "${NAMESPACE}"
ks param set --env=${ENV} ${WORKFLOW} name ${NAME}
ks param set --env=${ENV} ${WORKFLOW} prow_env "${PROW_VAR}"

ks apply ${ENV} -c ${WORKFLOW}
popd 

kubectl config use-context kubeflow-testing
kubectl get wf -o yaml ${NAME}
echo WORKFLOW=${NAME}
echo UI URL
URL=http://testing-argo.kubeflow.org/workflows/kubeflow-test-infra/${NAME}
echo ${URL}
google-chrome ${URL}&

# Switch to the context where the workflow runs
kubectl config use-context kf-v0-4-n00