#!/bin/bash
set -ex
TF_JOB_VERSION="v1alpha2"
JOB_NAME="tf-operator-release-${TF_JOB_VERSION}"
JOB_TYPE=presubmit
BUILD_NUMBER=$(uuidgen)
BUILD_NUMBER=${BUILD_NUMBER:0:4}
REPO_OWNER=kubeflow
REPO_NAME=tf-operator
ENV=test
DATE=`date +%Y%m%d`
NAMESPACE=kubeflow-test-infra
PULL_NUMBER=646
# Don't set PULL_PULL_SHA if you want to pull the head of the PR.
# PULL_PULL_SHA=0bc73dc

PROW_VAR="JOB_NAME=${JOB_NAME},JOB_TYPE=${JOB_TYPE},REPO_NAME=${REPO_NAME}"
PROW_VAR="${PROW_VAR},REPO_OWNER=${REPO_OWNER},BUILD_NUMBER=${BUILD_NUMBER}" 

if [ "${JOB_TYPE}" == "presubmit" ]; then
	PROW_VAR="${PROW_VAR},PULL_NUMBER=${PULL_NUMBER}"
	if [ ! -z "${PULL_PULL_SHA}" ]; then
		PROW_VAR="${PROW_VAR},PULL_PULL_SHA=${PULL_PULL_SHA}"
	fi
	VERSION_TAG="v${DATE}-pr${PULL_NUMBER}-${PULL_PULL_SHA}-${BUILD_NUMBER}"	
fi

ks param set --env=${ENV} workflows namespace "${NAMESPACE}"
ks param set --env=${ENV} workflows name "${USER}-${JOB_NAME}-${PULL_NUMBER}-${BUILD_NUMBER}"
ks param set --env=${ENV} workflows prow_env "${PROW_VAR}"
ks param set --env=${ENV} workflows versionTag "${VERSION_TAG}"
ks param set --env=${ENV} workflows tfJobVersion "${TF_JOB_VERSION}"
ks apply ${ENV} -c workflows