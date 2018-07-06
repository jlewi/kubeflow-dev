#!/bin/bash
set -ex
JOB_NAME="notebook-release"


DATE=`date +%Y%m%d`

JOB_NAME="tensorflow-notebook-image-release"
#JOB_TYPE=postsubmit
JOB_TYPE=presubmit

BUILD_NUMBER=$(uuidgen)
BUILD_NUMBER=${BUILD_NUMBER:0:4}
REPO_OWNER=kubeflow
REPO_NAME=kubeflow

ENV=releasing
DATE=`date +%Y%m%d-%H%M`

PROW_VAR="JOB_NAME=${JOB_NAME},JOB_TYPE=${JOB_TYPE},REPO_NAME=${REPO_NAME},REPO_OWNER=${REPO_OWNER},BUILD_NUMBER=${BUILD_NUMBER}" 

cd /home/jlewi/git_kubeflow/components/tensorflow-notebook-image/releaser

if [ "${JOB_TYPE}" == "presubmit" ]; then
	# Set pull number
	PULL_NUMBER=1136

	# By not setting PULL_PULL_SHA we should use the head of the PR branch.
	PROW_VAR="${PROW_VAR},PULL_NUMBER=${PULL_NUMBER}"
	VERSION_TAG="v${DATE}-pr${PULL_NUMBER}-${BUILD_NUMBER}"	
	WORKFLOW_NAME="${USER}-${JOB_NAME}-${PULL_NUMBER}-${BUILD_NUMBER}"
fi

if [ "${JOB_TYPE}" == "postsubmit" ]; then
	COMMIT=a50c2fb0e46cb3d9812be1ea1623749e13f63191
	PULL_BASE_SHA=${COMMIT:0:8}
	VERSION_TAG="v${DATE}-${PULL_BASE_SHA}"
	WORKFLOW_NAME="${USER}-${JOB_NAME}-${VERSION_TAG}"
fi

ks param set --env=${ENV} workflows namespace kubeflow-releasing
ks param set --env=${ENV} workflows name "${WORKFLOW_NAME}"
ks param set --env=${ENV} workflows prow_env "${PROW_VAR}"
ks param set --env=${ENV} workflows versionTag "${VERSION_TAG}"
ks apply ${ENV} -c workflows
