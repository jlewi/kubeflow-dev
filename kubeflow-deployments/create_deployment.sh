#!/bin/bash
# A script to facilitate redeploying Kubeflow using the latest templates.
#
set -ex
while [ "$1" != "" ]; do
case $1 in
	--project )                  shift
                                 PROJECT=$1
                                 ;;
  esac
  shift
done

if [ -z "${PROJECT}" ]; then
  echo --project must be set
fi

SUFFIX=$(date "+%m%d")

KFCTL="/home/jlewi/git_kubeflow/scripts/kfctl.sh"

APP="${USER}-${SUFFIX}"

${KFCTL} init ${APP} --platform gcp
