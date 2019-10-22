#!/bin/bash
#
# A hack script for rerunning the kfctl commands. 
# Intended for quick iteration during development
set -ex

BOOTSTRAPDIR=/home/jlewi/git_kubeflow-kubeflow/bootstrap

APPNAME=kftest-$(date +%m%d-%H%M%S)
APPDIR=/home/jlewi/git_jlewi-kubeflow-dev/kubeflow-deployments/${APPNAME}

# Source iap secrets
. ~/secrets/jlewi-dev.oauth.sh 

cd ${BOOTSTRAPDIR}
make build-kfctl

KFCTL=${BOOTSTRAPDIR}/bin/kfctl

mkdir -p ${APPDIR}
cp /home/jlewi/git_kubeflow-manifests/kfdef/kfctl_gcp_iap.yaml ${APPDIR}/

CFGFILE=${APPDIR}/kfctl_gcp_iap.yaml

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