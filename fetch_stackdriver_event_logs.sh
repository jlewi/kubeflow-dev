#!/bin/bash
# Fetch pod event logs for the test cluster.
set -ex
project=$1
POD=$2

FILTER="resource.labels.cluster_name=\"${PROJECT}\""
FILTER="${FILTER} resource.type=\"k8s_pod\" resource.labels.pod_name=\"${POD}\" "


# The full filter doesn't seem to work. Something doesn't seem to match
# filtering just by pod_id appears to work though
#"resource.type=\"container\" and resource.labels.cluster_name=\"${CLUSTER}\" and resource.labels.pod_id=\"${POD}\" and resource.labels.container_name=\"main\""
#--format="table(timestamp, resource.labels.pod_name, jsonPayload.reason, jsonPayload.message)"
LOGFILE=/home/jlewi/tmp/${POD}.event.log.txt
gcloud --project=${PROJECT} logging read  \
	--format="table(timestamp, resource.labels.pod_name, jsonPayload.reason, jsonPayload.message)" \
	--freshness=24h \
	--order asc \
    "${FILTER}" > ${LOGFILE}

cat ${LOGFILE}
echo Logs written to ${LOGFILE}
