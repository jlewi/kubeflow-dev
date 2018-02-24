#!/bin/bash
set -ex
JOB_NAME="kubeflow-kubeflow-presubmit-test"
PULL_NUMBER=227
BUILD_NUMBER=$(uuidgen)
BUILD_NUMBER=${BUILD_NUMBER:0:4}
REPO_OWNER=kubeflow
REPO_NAME=kubeflow
ks param set workflows name "${USER}-${JOB_NAME}-${PULL_NUMBER}-${BUILD_NUMBER}"
ks param set workflows prow_env "JOB_NAME=${JOB_NAME},JOB_TYPE=presubmit,PULL_NUMBER=${PULL_NUMBER},REPO_NAME=${REPO_NAME},REPO_OWNER=${REPO_OWNER},BUILD_NUMBER=${BUILD_NUMBER}"
ks apply prow -c workflows