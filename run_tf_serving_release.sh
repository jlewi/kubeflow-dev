#!/bin/bash
set -ex
PULL_BASE_SHA="master"
DATE=`date +%Y%m%d`
VERSION_TAG="v${DATE}-${PULL_BASE_SHA}"
JOB_NAME="tf-serving-release"
JOB_TYPE=postsubmit
BUILD_NUMBER=$(uuidgen)
BUILD_NUMBER=${BUILD_NUMBER:0:4}
REPO_OWNER=kubeflow
REPO_NAME=kubeflow

ENV=releasing
ks param set --env=${ENV} workflows namespace kubeflow-releasing
ks param set --env=${ENV} workflows name "${USER}-${JOB_NAME}-${VERSION_TAG}-${BUILD_NUMBER}"
ks param set --env=${ENV} workflows prow_env "JOB_NAME=${JOB_NAME},JOB_TYPE=${JOB_TYPE},PULL_BASE_SHA=${PULL_BASE_SHA},REPO_NAME=${REPO_NAME},REPO_OWNER=${REPO_OWNER},BUILD_NUMBER=${BUILD_NUMBER}"
ks param set --env=${ENV} workflows serving_image "gcr.io/kubeflow-images-staging/tf-model-server:${VERSION_TAG}"
ks apply ${ENV} -c workflows