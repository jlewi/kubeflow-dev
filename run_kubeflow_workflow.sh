#!/bin/bash
#
# This script is running the gke_deploy workflow E2E test.
# Its currently pointing at a pull request against jlewi/kubeflow as opposed
# to a pull request against kubeflow/kubeflow. This makes it easy 
# to checkout the updated code without having to create a WIP PR against the main repo.
set -ex
JOB_NAME="kubeflow-gke-deploy-test"
PULL_NUMBER=4
BUILD_NUMBER=$(uuidgen)
BUILD_NUMBER=${BUILD_NUMBER:0:4}
REPO_OWNER=jlewi
REPO_NAME=kubeflow
ENV=kubeflow-testing
ks param set workflows name "${USER}-${JOB_NAME}-${PULL_NUMBER}-${BUILD_NUMBER}"
ks param set workflows prow_env "JOB_NAME=${JOB_NAME},JOB_TYPE=presubmit,PULL_NUMBER=${PULL_NUMBER},REPO_NAME=${REPO_NAME},REPO_OWNER=${REPO_OWNER},BUILD_NUMBER=${BUILD_NUMBER}"
#ks param set workflows platform "gke"
ks apply ${ENV} -c gke_deploy