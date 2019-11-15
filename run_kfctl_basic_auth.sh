#!/bin/bash
#
# A hack script for rerunning the kfctl commands. 
# Intended for quick iteration during development
#
# Deploys with basic auth
set -ex

BOOTSTRAPDIR=/home/jlewi/git_kubeflow-kubeflow/bootstrap

APPNAME=kfbasic-$(date +%m%d-%H%M%S)
APPDIR=/home/jlewi/git_jlewi-kubeflow-dev/kubeflow-deployments/${APPNAME}

# Source iap secrets
. ~/secrets/jlewi-kf-basic-auth.sh 

cd ${BOOTSTRAPDIR}
make build-kfctl

KFCTL=${BOOTSTRAPDIR}/bin/kfctl

mkdir -p ${APPDIR}

MANIFESTSDIR=/home/jlewi/git_kubeflow-manifests/kfdef
if [ -f ${MANIFESTSDIR}/kfctl_gcp_basic_auth.0.7.0.yaml ]; then
	CFGNAME=kfctl_gcp_basic_auth.0.7.0.yaml
else
	CFGNAME=kfctl_gcp_basic.yaml
fi

cp ${MANIFESTSDIR}/${CFGNAME} ${APPDIR}/

CFGFILE=${APPDIR}/${CFGNAME}

# Zero out the name 
PROJECT=jlewi-dev
ZONE=us-east1-d

yq w -i ${CFGFILE} metadata.name "" 
yq w -i ${CFGFILE} spec.project ${PROJECT}   # Work around for 
yq w -i ${CFGFILE} spec.zone ${ZONE}   # Work around for https://github.com/kubeflow/kubeflow/issues/3703
 
# Use local manifests
yq w -i ${CFGFILE} spec.repos[0].uri /home/jlewi/git_kubeflow-manifests
#--use_basic_auth

${KFCTL} apply all -V  -f ${CFGFILE}