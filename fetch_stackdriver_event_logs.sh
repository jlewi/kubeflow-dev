#!/bin/bash
# Fetch pod event logs for the test cluster.
set -ex
POD=$1

FILTER="resource.labels.cluster_name=\"kubeflow-testing\""
FILTER="${FILTER} resource.type=\"k8s_pod\" resource.labels.pod_name=\"${POD}\" "


# The full filter doesn't seem to work. Something doesn't seem to match
# filtering just by pod_id appears to work though
#"resource.type=\"container\" and resource.labels.cluster_name=\"${CLUSTER}\" and resource.labels.pod_id=\"${POD}\" and resource.labels.container_name=\"main\""
#--format="table(timestamp, resource.labels.pod_name, jsonPayload.reason, jsonPayload.message)"
gcloud --project=kubeflow-ci logging read  \
	--format="table(timestamp, resource.labels.pod_name, jsonPayload.reason, jsonPayload.message)" \
	--freshness=24h \
	--order asc \
    "${FILTER}" > /tmp/$1.event.log.txt

cat /tmp/$1.event.log.txt
echo Logs written to /tmp/$1.event.log.txt
