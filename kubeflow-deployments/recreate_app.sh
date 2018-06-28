#!/bin/bash
#
# A simple script to recreate the Kubeflow app for  jlewi-kubeflow.
# The purpose of this script is to make it easy to pull in the latest
# release.
#
# By design this script doesn't actually modify the current deployment
# (e.g. delete the current namespace or apply the deployment)
set -ex
# Create a namespace for kubeflow deployment
NAMESPACE=kubeflow

# Which version of Kubeflow to use
# For a list of releases refer to:
# https://github.com/kubeflow/kubeflow/releases
VERSION=master
#API_VERSION=v1.7.0


APP_LOCATION=$1
APP_DIR=`dirname ${APP_LOCATION}`
APP_NAME=`basename ${APP_LOCATION}`

if [ -d ${APP_LOCATION} ]; then
	# TODO(jlewi): Maybe we should prompt to ask if we want to delete?
	echo "Directory ${APP_LOCATION} exists"
	echo "Do you want to delete ${APP_LOCATION} y/n[n]:"
	read response

	if [ "${response}"=="y" ]; then
		rm -r ${APP_LOCATION}
	else
		"Aborting"
		exit 1
	fi
fi
cd ${APP_DIR}
#ks init ${APP_NAME} --api-spec=version:${API_VERSION}
ks init ${APP_NAME}
cd ${APP_NAME}
ks env set default --namespace ${NAMESPACE}

#
# Install Kubeflow components
ks registry add kubeflow github.com/kubeflow/kubeflow/tree/${VERSION}/kubeflow

ks pkg install kubeflow/core@${VERSION}
ks pkg install kubeflow/examples@${VERSION}
ks pkg install kubeflow/tf-serving@${VERSION}
ks pkg install kubeflow/tf-job@${VERSION}
ks pkg install kubeflow/seldon@${VERSION}
ks pkg install kubeflow/katib@${VERSION}

# Create templates for core components
ks generate kubeflow-core kubeflow-core

# Setup ingress
ACCOUNT=jlewi@google.com
FQDN=jlewi-kubeflow.endpoints.cloud-ml-dev.cloud.goog
IP_NAME="jlewi-kubeflow-ip"
ks generate cert-manager cert-manager --acmeEmail=${ACCOUNT}
ks generate iap-ingress iap-ingress --namespace=${NAMESPACE} \
       --ipName=${IP_NAME} \
       --hostname="${FQDN}" \
       --oauthSecretName="kubeflow-oauth"

# Create katib components
ks generate katib katib

ks param set kubeflow-core jupyterHubAuthenticator iap

# Enable a PVC backed by the default StorageClass
ks param set kubeflow-core jupyterNotebookPVCMount /home/jovyan --env=default

