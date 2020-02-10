#!/bin/bash
# Fetch pod event logs for the test cluster.
set -ex
PROJECT=$1
CLUSTER=$2
OBJECT=$3
FRESHNESS="${FRESHNESS:-24h}"
FILTER="resource.labels.cluster_name=\"${CLUSTER}\""
FILTER="${FILTER} logName=\"projects/${PROJECT}/logs/events\" "
FILTER="${FILTER} jsonPayload.involvedObject.name=\"${OBJECT}\""


LOGFILE=/home/jlewi/tmp/${OBJECT}.${CLUSTER}.logs.txt
gcloud --project=${PROJECT} logging read  \
		--format="table(timestamp, jsonPayload.involvedObject.namespace, jsonPayload.involvedObject.name, jsonPayload.message)" \
        --freshness=${FRESHNESS} \
        --order asc \
	    "${FILTER}" > ${LOGFILE}

cat ${LOGFILE}
echo Logs written to ${LOGFILE}
