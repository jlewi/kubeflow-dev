#!/bin/bash
set -ex
JOB_NAME="notebook-release"
# TODO(jlewi): Really should be using a post submit.
JOB_TYPE=presubmit
BUILD_NUMBER=$(uuidgen)
BUILD_NUMBER=${BUILD_NUMBER:0:4}
REPO_OWNER=kubeflow
REPO_NAME=kubeflow

ENV=releasing
DATE=`date +%Y%m%d-%H%M`

PULL_NUMBER=328
PULL_PULL_SHA=0bc73dc

PROW_VAR="JOB_NAME=${JOB_NAME},JOB_TYPE=${JOB_TYPE},REPO_NAME=${REPO_NAME},REPO_OWNER=${REPO_OWNER},BUILD_NUMBER=${BUILD_NUMBER}" 

if [ "${JOB_TYPE}" == "presubmit" ]; then
	PROW_VAR="${PROW_VAR},PULL_NUMBER=${PULL_NUMBER},PULL_PULL_SHA=${PULL_PULL_SHA}"
	VERSION_TAG="v${DATE}-pr${PULL_NUMBER}-${PULL_PULL_SHA}-${BUILD_NUMBER}"	
fi

ks param set --env=${ENV} workflows namespace kubeflow-releasing
ks param set --env=${ENV} workflows name "${USER}-${JOB_NAME}-${PULL_NUMBER}-${BUILD_NUMBER}"
ks param set --env=${ENV} workflows prow_env "${PROW_VAR}"
ks param set --env=${ENV} workflows versionTag "${VERSION_TAG}"
ks apply ${ENV} -c workflows