#!/bin/bash
set -ex
CLUSTER=$1
POD=$2

# The full filter doesn't seem to work. Something doesn't seem to match
# filtering just by pod_id appears to work though
#"resource.type=\"container\" and resource.labels.cluster_name=\"${CLUSTER}\" and resource.labels.pod_id=\"${POD}\" and resource.labels.container_name=\"main\""
gcloud --project=kubeflow-ci logging read  \
	--freshness=24h \
	--order asc \
    "resource.type=\"container\" resource.labels.cluster_name=\"${CLUSTER}\" resource.labels.pod_id=\"${POD}\" resource.labels.container_name=\"main\" "
