#!/bin/bash
#
# Download the registry and scripts.
# This is the first step in setting up Kubeflow.
#
# To use a local directory set environment variable KUBEFLOW_SOURCE
set -ex

# The subdirectory to store the files in.
KUBEFLOW_REPO=kubeflow_repo
KUBEFLOW_CLOUD=${KUBEFLOW_CLOUD:-generic}
if [ ! -z "${KUBEFLOW_VERSION}" ]; then
	KUBEFLOW_TAG=v${KUBEFLOW_VERSION}
fi

KUBEFLOW_TAG=${KUBEFLOW_TAG:-master}

if [ -d "${KUBEFLOW_REPO}" ]; then
  echo Directory ${KUBEFLOW_REPO} already exists
  exit 1
fi

# Create a local copy of the Kubeflow source repo
# Override KUBEFLOW_SOURCE to point 
if [ -z ${KUBEFLOW_SOURCE} ]; then
  TMPDIR=$(mktemp -d /tmp/tmp.kubeflow-repo-XXXX)
  curl -L -o ${TMPDIR}/kubeflow.tar.gz https://github.com/kubeflow/kubeflow/archive/${KUBEFLOW_TAG}.tar.gz
  tar -xzvf ${TMPDIR}/kubeflow.tar.gz  -C ${TMPDIR}
  # GitHub seems to strip out the v in the file name.
  KUBEFLOW_SOURCE=$(find ${TMPDIR} -maxdepth 1 -type d -name "kubeflow*")
fi 

# Copy over the directories we need
mkdir -p "${KUBEFLOW_REPO}"
cp -r ${KUBEFLOW_SOURCE}/kubeflow "${KUBEFLOW_REPO}"/
cp -r ${KUBEFLOW_SOURCE}/scripts "${KUBEFLOW_REPO}"/


if [ "${KUBEFLOW_CLOUD}" == "gke" ]; then
  echo creating links for gke
  SCRIPTS_DIR=${KUBEFLOW_REPO}/scripts/gke
fi

if [ "${KUBEFLOW_CLOUD}" == "generic" ]; then
  echo creating links for generic platform
  SCRIPTS_DIR=${KUBEFLOW_REPO}/scripts
fi

if [ ! -f "deploy.sh" ]; then
  ln -sf ${SCRIPTS_DIR}/deploy.sh deploy.sh
fi

if [ ! -f "teardown.sh" ]; then
  if [ -f ${SCRIPTS_DIR}/teardown.sh ]; then
  	ln -sf ${SCRIPTS_DIR}/teardown.sh teardown.sh
  fi
fi
