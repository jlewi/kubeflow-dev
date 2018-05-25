#!/bin/bash
# Fetch some events from stackdriver
set -ex
EXTRA=$1

FILTER="resource.labels.cluster_name=\"kubeflow-testing\""
FILTER="${FILTER} logName=\"projects/kubeflow-ci/logs/events\" "
FILTER="${FILTER} \"${EXTRA}\""


# The full filter doesn't seem to work. Something doesn't seem to match
# filtering just by pod_id appears to work though
#"resource.type=\"container\" and resource.labels.cluster_name=\"${CLUSTER}\" and resource.labels.pod_id=\"${POD}\" and resource.labels.container_name=\"main\""
gcloud --project=kubeflow-ci logging read  \
	--freshness=24h \
	--order asc \
    "${FILTER}"
