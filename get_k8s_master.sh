#!/bin/bash
set -x
# This doesn't work.
# There's something wrong about how the text is in KUBE_INFO if you copy and paste that
# data backs it works.

KS_ENV=test
KS_ENV_INFO=$(ks env describe ${KS_ENV})

KUBE_INFO=$(kubectl cluster-info)
KS_MASTER=$(expr match "${KS_ENV_INFO}" '.*server[^\.0-9]*\([\.0-9]\+\)')
echo KS_MASTER=${KS_MASTER}
MASTER=$(expr match "${KUBE_INFO}" '[^\.0-9]*\([\.0-9]\+\)')


echo "${KUBE_INFO}" > /tmp/kube_info.txt
echo MASTER=${MASTER}
if [[ "${MASTER}" != "${KS_MASTER}" ]]; then
  echo "The current kubectl context doesn't match the ks environment"
  echo "Please configure the context to match ks environment ${KS_ENV}"
  exit -1
else
  echo kubectl context matches ks environment ${KS_ENV}
fi