#!/bin/bash
# This script creates a kubeflow deployment on minikube
# It checks for kubectl, ks
# Creates the ksonnet app, installs packages, components and then applies them

set -xe

KUBEFLOW_REPO=${KUBEFLOW_REPO:-"`pwd`/kubeflow_repo"}
KUBEFLOW_VERSION=${KUBEFLOW_VERSION:-"master"}
KUBEFLOW_DEPLOY=${KUBEFLOW_DEPLOY:-true}
K8S_NAMESPACE=${K8S_NAMESPACE:-"kubeflow"}
KUBEFLOW_CLOUD=${KUBEFLOW_CLOUD:-"minikube"}

source "${KUBEFLOW_REPO}/scripts/util.sh"

# TODO(ankushagarwal): verify ks version is higher than 0.11.0
check_install ks
check_install kubectl
check_install uuidgen

# Name of the deployment
DEPLOYMENT_NAME=${DEPLOYMENT_NAME:-"kubeflow"}

KUBEFLOW_KS_DIR=${KUBEFLOW_KS_DIR:-"`pwd`/${DEPLOYMENT_NAME}_ks_app"}

cd $(dirname "${KUBEFLOW_KS_DIR}")

set +e
kubectl create ns ${K8S_NAMESPACE}
set -e

ks init $(basename "${KUBEFLOW_KS_DIR}")
cd "${KUBEFLOW_KS_DIR}"

ks env set default --namespace "${K8S_NAMESPACE}"

# Add the local registry
ks registry add kubeflow "${KUBEFLOW_REPO}/kubeflow"

# Install packages
ks pkg install kubeflow/argo
ks pkg install kubeflow/core
ks pkg install kubeflow/examples
ks pkg install kubeflow/katib
ks pkg install kubeflow/mpi-job
ks pkg install kubeflow/pytorch-job
ks pkg install kubeflow/seldon
ks pkg install kubeflow/tf-serving

# Generate all required components
ks generate ambassador ambassador --cloud=${KUBEFLOW_CLOUD}
ks generate jupyterhub jupyterhub --cloud=${KUBEFLOW_CLOUD}
ks generate centraldashboard centraldashboard
ks generate tf-job-operator tf-job-operator
# Enable collection of anonymous usage metrics
# Skip this step if you don't want to enable collection.
ks generate spartakus spartakus --usageId=$(uuidgen) --reportUsage=true
ks generate argo argo

# Apply the components generated
if ${KUBEFLOW_DEPLOY}; then
  ks apply default
fi
