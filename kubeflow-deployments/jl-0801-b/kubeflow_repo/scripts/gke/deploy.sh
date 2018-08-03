#!/bin/bash
# This script creates a kubeflow deployment on GCP
# It checks for kubectl, gcloud, ks
# Uses default PROJECT, ZONE, EMAIL from gcloud config
# Creates a deployment manager config copy and edits appropriate values
# Adds user to the IAP role
# Creates the deployment
# Creates the ksonnet app, installs packages, components and then applies them
#
# To avoid using GCFS set GCFS_INSTANCE to null like so
# export GCFS_INSTANCE=
set -xe

COMMAND=$1

if [ -z "${COMMAND}" ]; then
	COMMAND=all
fi	
# TODO(jlewi): We should check for a file env.sh and if it exists
# source variables from it. We should then create that file the
# first time we run deploy.sh

KUBEFLOW_CLOUD="gke"

ENV_FILE="`pwd`/env.sh"

usage() {
    echo "usage: deploy.sh <command>"
    echo "where command is one of"
    echo "all - run all the steps"
    echo "configure - creates deployment and ksonnet configs"
    echo "update - creates/updates the deployment"
    echo "setup_project - perform onetime setup of the project"
    echo "help - print this message"       
}

createOrSourceEnv() {
	# Check if there is a file env.sh
	# If there is source it otherwise create it.
	# this ensures all relevant environment variables are persisted in
	# a file for consistency across runs.

	if [ ! -f ${ENV_FILE} ]; then
		PROJECT=${PROJECT:-$(gcloud config get-value project 2>/dev/null)}
		echo PROJECT="${PROJECT}" >> ${ENV_FILE}
		if [ -z "${PROJECT}" ]; then
			echo PROJECT must be set either using environment variable PROJECT
			echo or by setting the default project in gcloud
			exit -1
		fi
		echo KUBEFLOW_REPO=${KUBEFLOW_REPO:-"`pwd`/kubeflow_repo"} >> ${ENV_FILE}
		echo KUBEFLOW_VERSION=${KUBEFLOW_VERSION:-"master"} >> ${ENV_FILE}
		echo KUBEFLOW_DEPLOY=${KUBEFLOW_DEPLOY:-true} >> ${ENV_FILE}

		# Name of the deployment
		DEPLOYMENT_NAME=${DEPLOYMENT_NAME:-"kubeflow"} 
		echo DEPLOYMENT_NAME="${DEPLOYMENT_NAME}" >> ${ENV_FILE}

		# We only set GCFS_INSTANCE to the default value if it is unset
		# but not if its null.
		# We use null to indicate we should not use GCFS
		echo GCFS_INSTANCE=${GCFS_INSTANCE-"${DEPLOYMENT_NAME}"} >> ${ENV_FILE}
		echo GCFS_STORAGE=${GCFS_STORAGE:-"1T"} >> ${ENV_FILE}

		# Kubeflow directories - Deployment Manager and Ksonnet App
		# TODO(jlewi): We should shorten the directory names. 
		# There's no reason to use ${DEPLOYMENT_NAME} as a prefix. Instead 
		# the pattern should be one directory per deployment and that directory
		# should have subdirectories for DM config, ksonnet app, and secrets.
		echo KUBEFLOW_DM_DIR=${KUBEFLOW_DM_DIR:-"`pwd`/dm_configs"} >> ${ENV_FILE}
		echo KUBEFLOW_KS_DIR=${KUBEFLOW_KS_DIR:-"`pwd`/ks_app"} >> ${ENV_FILE}
		echo KUBEFLOW_SECRETS_DIR=${KUBEFLOW_SECRETS_DIR:-"`pwd`/secrets"} >> ${ENV_FILE}
		echo KUBEFLOW_K8S_MANIFESTS_DIR="`pwd`/k8s_specs" >> ${ENV_FILE}
		# GCP Project
		
		# GCP Zone
		ZONE=${ZONE:-$(gcloud config get-value compute/zone 2>/dev/null)}
		echo ZONE=${ZONE:-"us-central1-a"} >> ${ENV_FILE}

		# Email for cert manager
		EMAIL=${EMAIL:-$(gcloud config get-value account 2>/dev/null)}
		echo EMAIL=${EMAIL} >> ${ENV_FILE}
		
		# GCP Static IP Name
		echo KUBEFLOW_IP_NAME=${KUBEFLOW_IP_NAME:-"${DEPLOYMENT_NAME}-ip"} >> ${ENV_FILE}
		# Name of the endpoint
		KUBEFLOW_ENDPOINT_NAME=${KUBEFLOW_ENDPOINT_NAME:-"${DEPLOYMENT_NAME}"}
		echo KUBEFLOW_ENDPOINT_NAME=${KUBEFLOW_ENDPOINT_NAME} >> ${ENV_FILE}
		# Complete hostname
		echo KUBEFLOW_HOSTNAME=${KUBEFLOW_HOSTNAME:-"${KUBEFLOW_ENDPOINT_NAME}.endpoints.${PROJECT}.cloud.goog"} >> ${ENV_FILE}

		# Namespace where kubeflow is deployed
		echo K8S_NAMESPACE=${K8S_NAMESPACE:-"kubeflow"} >> ${ENV_FILE}
		echo CONFIG_FILE=${CONFIG_FILE:-"cluster-kubeflow.yaml"} >> ${ENV_FILE}

		if [ -z "${PROJECT_NUMBER}" ]; then
		  PROJECT_NUMBER=`gcloud projects describe ${PROJECT} --format='value(project_number)'`
		fi

		echo PROJECT_NUMBER=${PROJECT_NUMBER} >> ${ENV_FILE}
		echo IAP_IAM_ENTRY=${IAP_IAM_ENTRY:-"user:${EMAIL}"} >> ${ENV_FILE}
    fi 
    source "${ENV_FILE}"
}

createSecretsDir() {
	mkdir -p ${KUBEFLOW_SECRETS_DIR}

	# We want to prevent secrets from being checked into source control.
	# We have two different checks.
	# 1. We put the secrets in a directory with a .gitignore file
	# 2. We will delete the secrets immediately.
	if [ ! -f ${KUBEFLOW_SECRETS_DIR}/.gitignore ]; then
  cat > ${KUBEFLOW_SECRETS_DIR}/.gitignore << EOF
**
EOF
	fi
}

createOrSourceEnv

if [[ ! -d "${KUBEFLOW_REPO}" ]]; then
  # Create a local copy of the Kubeflow source repo
  # Override SOURCE_DIR to point 
  if [ -z ${SOURCE_DIR} ]; then
	  if [ "${KUBEFLOW_VERSION}" == "master" ]; then
	    TAG=${KUBEFLOW_VERSION}
	  else
	    TAG=v${KUBEFLOW_VERSION}
	  fi
	  TMPDIR=$(mktemp -d /tmp/tmp.kubeflow-repo-XXXX)
	  curl -L -o ${TMPDIR}/kubeflow.tar.gz https://github.com/kubeflow/kubeflow/archive/${TAG}.tar.gz
	  tar -xzvf ${TMPDIR}/kubeflow.tar.gz  -C ${TMPDIR}
	  # GitHub seems to strip out the v in the file name.
	  SOURCE_DIR=$(find ${TMPDIR} -maxdepth 1 -type d -name "kubeflow*")
  fi 

  # Copy over the directories we need
  mkdir -p "${KUBEFLOW_REPO}"
  cp -r  ${SOURCE_DIR}/kubeflow "${KUBEFLOW_REPO}"/
  cp -r ${SOURCE_DIR}/scripts "${KUBEFLOW_REPO}"/

  if [ ! -f "deploy.sh" ]; then
  	ln -sf ${KUBEFLOW_REPO}/scripts/gke/deploy.sh deploy.sh
  	ln -sf ${KUBEFLOW_REPO}/scripts/gke/teardown.sh teardown.sh
  fi
fi

source "${KUBEFLOW_REPO}/scripts/util.sh"

check_install gcloud
check_install kubectl
# TODO(ankushagarwal): verify ks version is higher than 0.11.0
check_install ks
check_install uuidgen

check_variable "${PROJECT}" "PROJECT"
check_variable "${EMAIL}" "EMAIL"
# TODO(jlewi): We should get rid of this. We are just duplicating
# the DM configs.
# If users want to use private cluster the flow should be.
# deploy.sh configure
# Edit YAML config to enable private cluster
# deploy.sh update
PRIVATE_CLUSTER=${PRIVATE_CLUSTER:-false}

createSecretsDir


# Whether to setup the project. Set to false to skip setting up the project.
SETUP_PROJECT=${SETUP_PROJECT:true}

ADMIN_EMAIL=${DEPLOYMENT_NAME}-admin@${PROJECT}.iam.gserviceaccount.com
USER_EMAIL=${DEPLOYMENT_NAME}-user@${PROJECT}.iam.gserviceaccount.com
COLLECT_METRICS=${COLLECT_METRICS:-true}

setupProject() {
  # Enable GCloud APIs
  gcloud services enable deploymentmanager.googleapis.com \
                         servicemanagement.googleapis.com \
                         container.googleapis.com \
                         cloudresourcemanager.googleapis.com \
                         endpoints.googleapis.com \
                         file.googleapis.com \
                         iam.googleapis.com --project=${PROJECT}

  # Set IAM Admin Policy
  gcloud projects add-iam-policy-binding ${PROJECT} \
     --member serviceAccount:${PROJECT_NUMBER}@cloudservices.gserviceaccount.com \
     --role roles/resourcemanager.projectIamAdmin
}

createDMConfigs() {
	# Create the DM configs if they don't exists
	if [ ! -d "${KUBEFLOW_DM_DIR}" ]; then
	  echo creating Deployment Manager configs in directory "${KUBEFLOW_DM_DIR}"
	  cp -r "${KUBEFLOW_REPO}/scripts/gke/deployment_manager_configs" "${KUBEFLOW_DM_DIR}"
	  # Set values in DM config file
	  sed -i.bak "s/zone: us-central1-a/zone: ${ZONE}/" "${KUBEFLOW_DM_DIR}/${CONFIG_FILE}"
	  sed -i.bak "s/users:/users: [\"${IAP_IAM_ENTRY}\"]/" "${KUBEFLOW_DM_DIR}/${CONFIG_FILE}"
	  sed -i.bak "s/ipName: kubeflow-ip/ipName: ${KUBEFLOW_IP_NAME}/" "${KUBEFLOW_DM_DIR}/${CONFIG_FILE}"
	  if ${PRIVATE_CLUSTER}; then
	    sed -i.bak "s/gkeApiVersion: v1/gkeApiVersion: v1beta1/" "${KUBEFLOW_DM_DIR}/${CONFIG_FILE}"
	    sed -i.bak "s/privatecluster: false/privatecluster: true/" "${KUBEFLOW_DM_DIR}/${CONFIG_FILE}"
	  fi
	  rm "${KUBEFLOW_DM_DIR}/${CONFIG_FILE}.bak"
	else
	  echo Deployment Manager configs already exist in directory "${KUBEFLOW_DM_DIR}"
	fi
}

createDMConfigs

cd "${KUBEFLOW_DM_DIR}"

# TODO(jlewi): Make GCFS creation a separate step.
# Create GCFS Instance in parallel with deployment manager to speed things up
#if [ ! -z ${GCFS_INSTANCE} ]; then

# TODO(jlewi): We should check if the GCFS_INSTANCE already exists and if not
# create it.
#gcloud beta filestore instances create ${GCFS_INSTANCE} \
#    --project=${PROJECT} \
#    --location=${ZONE} \
#    --tier=STANDARD \
#    --file-share=name=kubeflow,capacity=${GCFS_STORAGE} \
#    --network=name="default" &
#gcfs_creation_pid=$!

#else
#  echo Not creating a filestore instance
#fi

createGcpSecret() {
  EMAIL=$1
  SECRET=$2

  O=`kubectl get secret --namespace=${K8S_NAMESPACE} ${SECRET} 2>&1`
  RESULT=$?

  if [ "${RESULT}" -eq 0 ]; then
    echo secret ${SECRET} already exists
    return
  fi

  FILE=${KUBEFLOW_SECRETS_DIR}/${EMAIL}.json
  gcloud --project=${PROJECT} iam service-accounts keys create ${FILE} --iam-account ${EMAIL}

  kubectl create secret generic --namespace=${K8S_NAMESPACE} ${SECRET} --from-file=${SECRET}.json=${FILE}

  # Delete the secret to reduce the risk of compromise
  rm ${FILE}
}

downloadK8sManifests() {
  mkdir -p ${KUBEFLOW_K8S_MANIFESTS_DIR} 
  # Install the GPU driver. It has no effect on non-GPU nodes.
  curl -o ${KUBEFLOW_K8S_MANIFESTS_DIR}/daemonset-preloaded.yaml \
  	https://raw.githubusercontent.com/GoogleCloudPlatform/container-engine-accelerators/stable/nvidia-driver-installer/cos/daemonset-preloaded.yaml

  curl -o ${KUBEFLOW_K8S_MANIFESTS_DIR}/rbac-setup.yaml \
	https://storage.googleapis.com/stackdriver-kubernetes/stable/rbac-setup.yaml

  curl -o ${KUBEFLOW_K8S_MANIFESTS_DIR}/agents.yaml \
  		  https://storage.googleapis.com/stackdriver-kubernetes/stable/agents.yaml

}

updateDM() {
  pushd .
  cd ${KUBEFLOW_DM_DIR}
  # Check if it already exists
  set +e
  gcloud deployment-manager --project=${PROJECT} deployments describe ${DEPLOYMENT_NAME}
  exists=$?

  if [ ${exists} -eq 0 ]; then
    echo ${DEPLOYMENT_NAME} exists
    gcloud deployment-manager --project=${PROJECT} deployments update ${DEPLOYMENT_NAME} --config=${CONFIG_FILE}
  else
    # Run Deployment Manager
    gcloud deployment-manager --project=${PROJECT} deployments create ${DEPLOYMENT_NAME} --config=${CONFIG_FILE}
  fi

  popd

  # Set credentials for kubectl context
  gcloud --project=${PROJECT} container clusters get-credentials --zone=${ZONE} ${DEPLOYMENT_NAME}

  # Make yourself cluster admin
  O=`kubectl get clusterrolebinding default-admin 2>&1`
  RESULT=$?

  if [ "${RESULT}" -eq 0 ]; then
    echo clusterrolebinding default-admin already exists
  else
    kubectl create clusterrolebinding default-admin --clusterrole=cluster-admin --user=${EMAIL}
  fi

  O=`kubectl get namespace ${K8S_NAMESPACE} 2>&1`
  RESULT=$?

  if [ "${RESULT}" -eq 0 ]; then
    echo namespace ${K8S_NAMESPACE} already exists
  else
    kubectl create namespace ${K8S_NAMESPACE}
  fi
  
  # Install the GPU driver. It has no effect on non-GPU nodes.
  kubectl apply -f ${KUBEFLOW_K8S_MANIFESTS_DIR}/daemonset-preloaded.yaml

  # Install Stackdriver Kubernetes agents.  
  kubectl apply -f ${KUBEFLOW_K8S_MANIFESTS_DIR}/rbac-setup.yaml --as=admin --as-group=system:masters
  kubectl apply -f ${KUBEFLOW_K8S_MANIFESTS_DIR}/agents.yaml

  set -e
}

createSecrets() {
  check_variable "${CLIENT_ID}" "CLIENT_ID"
  check_variable "${CLIENT_SECRET}" "CLIENT_SECRET"

  # We want the secret name to be the same by default for all clusters so that users don't have to set it manually.
  createGcpSecret ${ADMIN_EMAIL} admin-gcp-sa
  createGcpSecret ${USER_EMAIL} user-gcp-sa
  
  O=`kubectl get secret --namespace=${K8S_NAMESPACE} kubeflow-oauth 2>&1`
  RESULT=$?

  if [ "${RESULT}" -eq 0 ]; then
    echo Secret kubeflow-oauth already exists
  else
    kubectl create secret generic --namespace=${K8S_NAMESPACE} kubeflow-oauth --from-literal=CLIENT_ID=${CLIENT_ID} --from-literal=CLIENT_SECRET=${CLIENT_SECRET}
  fi
}
# TODO(jlewi): Need to move GCFS creation into separate step
#GCFS_INSTANCE_IP_ADDRESS=$(gcloud beta filestore instances describe \
# ${GCFS_INSTANCE} --location ${ZONE} | \
# grep --after-context=1 ipAddresses | \
# tail -1 | \
# awk '{print $2}')
#fi

createKsApp() {
  pushd . 
  # Create the ksonnet app
  cd $(dirname "${KUBEFLOW_KS_DIR}")
  ks init $(basename "${KUBEFLOW_KS_DIR}")
  cd "${KUBEFLOW_KS_DIR}"

  # Remove the default environment; it will be pointing
  # at the wrong cluster since the cluster doesn't exist yet
  ks env rm default

  # Add the local registry
  ks registry add kubeflow "${KUBEFLOW_REPO}/kubeflow"

  # Install all required packages
  ks pkg install kubeflow/argo
  ks pkg install kubeflow/core
  ks pkg install kubeflow/examples
  ks pkg install kubeflow/katib
  ks pkg install kubeflow/mpi-job
  ks pkg install kubeflow/pytorch-job
  ks pkg install kubeflow/seldon
  ks pkg install kubeflow/tf-serving

  # Generate all required components
  ks generate pytorch-operator pytorch-operator
  # TODO(jlewi): Why are we overloading the ambassador images here?
  ks generate ambassador ambassador --ambassadorImage="gcr.io/kubeflow-images-public/ambassador:0.30.1" --statsdImage="gcr.io/kubeflow-images-public/statsd:0.30.1" --cloud=${KUBEFLOW_CLOUD}
  ks generate jupyterhub jupyterhub --cloud=${KUBEFLOW_CLOUD}
  ks generate centraldashboard centraldashboard
  ks generate tf-job-operator tf-job-operator

  ks generate argo argo

  # Enable collection of anonymous usage metrics
  # Skip this step if you don't want to enable collection.
  ks generate spartakus spartakus --usageId=$(uuidgen) --reportUsage=${COLLECT_METRICS}
  ks generate cloud-endpoints cloud-endpoints
  ks generate cert-manager cert-manager --acmeEmail=${EMAIL}
  ks generate iap-ingress iap-ingress --ipName=${KUBEFLOW_IP_NAME} --hostname=${KUBEFLOW_HOSTNAME}
  ks param set jupyterhub jupyterHubAuthenticator iap
  popd
}

ksApply() {
  # Apply the components generated
  cd "${KUBEFLOW_KS_DIR}"

  O=`ks env describe default 2>&1`
  RESULT=$?

  if [ "${RESULT}" -eq 0 ]; then
  	ks env add default --namespace "${K8S_NAMESPACE}"
  else  	
    echo environment env already exists
  fi

  #if ${KUBEFLOW_DEPLOY}; then
  #if [ ! -z ${GCFS_INSTANCE} ]; then
  #  ks apply default -c google-cloud-filestore-pv
  #fi

  ks apply default -c ambassador
  ks apply default -c jupyterhub
  ks apply default -c centraldashboard
  ks apply default -c tf-job-operator
  ks apply default -c argo
  ks apply default -c spartakus
  ks apply default -c cloud-endpoints
  ks apply default -c cert-manager
  ks apply default -c iap-ingress
  ks apply default -c pytorch-operator

  popd
}

if [ "${COMMAND}" == "setup_project" ]; then
	setupProject
fi	

if [ "${COMMAND}" == "configure" ]; then
	createDMConfigs	
	downloadK8sManifests
	createKsApp
fi

if [ "${COMMAND}" == "update" ]; then
	updateDM
	createSecrets
	ksApply
fi

if [ "{$COMMAND}" == "all" ]; then
	setupProject
	createDMConfigs
	downloadK8sManifests
	createKsApp
	updateDM
	createSecrets
	ksApply
fi	
