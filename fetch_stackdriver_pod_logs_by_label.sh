#!/bin/bash
# Fetch some events from stackdriver
set -ex
PROJECT=$1
LABEL=$2
VALUE=$3

OUTFILE=~/tmp/${PROJECT}.${LABEL}.value.txt
gcloud logging read --format="table(timestamp, resource.labels.pod_name, resource.labels.container_name, textPayload, jsonPayload.msg) " \
	--freshness=6h \
	--project=${PROJECT} \
	"resource.type=\"k8s_container\" metadata.userLabels.${LABEL} =\"${VALUE}\"  " > ${OUTFILE}

cat ${OUTFILE}
echo Logs written to ${OUTFILE}
