#!/bin/bash
set -ex
JOB_NAME="tf-operator-release"
# TODO(jlewi): Really should be using a post submit.
PULL_NUMBER=403
JOB_TYPE=presubmit
BUILD_NUMBER=$(uuidgen)
BUILD_NUMBER=${BUILD_NUMBER:0:4}
REPO_OWNER=kubeflow
REPO_NAME=tf-operator
ENV=releasing
DATE=`date +%Y%m%d`
VERSION_TAG="v${DATE}-${PULL_NUMBER}"
ks param set --env=${ENV} workflows namespace kubeflow-releasing
ks param set --env=${ENV} workflows name "${USER}-${JOB_NAME}-${PULL_NUMBER}-${BUILD_NUMBER}"
ks param set --env=${ENV} workflows prow_env "JOB_NAME=${JOB_NAME},JOB_TYPE=${JOB_TYPE},PULL_NUMBER=${PULL_NUMBER},REPO_NAME=${REPO_NAME},REPO_OWNER=${REPO_OWNER},BUILD_NUMBER=${BUILD_NUMBER}"
ks param set --env=${ENV} workflows versionTag "${VERSION_TAG}"
ks apply ${ENV} -c workflows