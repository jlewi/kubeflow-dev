#!/bin/bash
#
# A hack script for rerunning the kfctl commands. 
# Intended for quick iteration during development
set -ex

BOOTSTRAPDIR=/home/jlewi/git_kubeflow-kfctl

APPNAME=jl-stack-$(date +%m%d-%H%M%S)
APPDIR=~/tmp/stack_apps/${APPNAME}

# Source iap secrets
. ~/secrets/jlewi-dev.oauth.sh 

cd ${BOOTSTRAPDIR}
make build-kfctl-fast

KFCTL=${BOOTSTRAPDIR}/bin/linux/kfctl

mkdir -p ${APPDIR}

MANIFESTSDIR=/home/jlewi/git_kubeflow-manifests/stacks/examples
CFGNAME=kfctl_gcp_stacks.experimental.yaml

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

${KFCTL} build all -V  -f ${CFGFILE}

# Generate the output for testing
cd ${APPDIR}/kustomize/kubeflow-apps
mkdir -p /tmp/stack_apps/${APPNAME}
kustomize build --load_restrictor none -o /tmp/stack_apps/${APPNAME}