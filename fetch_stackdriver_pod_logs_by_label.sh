#!/bin/bash
# Fetch some events from stackdriver
set -ex
PROJECT="${PROJECT:-kubeflow-ci}"
LABEL="${LABEL:-tekton_dev/taskRun}"
FRESHNESS="${FRESHNESS:-24h}"
VALUE="${VALUE:-notset}"
OUTFILE=~/tmp/${PROJECT}.value.txt
gcloud logging read --format="table(timestamp, resource.labels.pod_name, resource.labels.container_name, textPayload, jsonPayload.msg) " \
	--freshness=${FRESHNESS} \
	--project=${PROJECT} \
	"resource.type=\"k8s_container\" labels.\"k8s-pod/${LABEL}\"=\"${VALUE}\"  " > ${OUTFILE}

cat ${OUTFILE}
echo Logs written to ${OUTFILE}
