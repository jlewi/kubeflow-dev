#!/bin/bash
# Fetch some events from stackdriver
set -ex
JOB=$1

OUTFILE=~/tmp/${JOB}.log.txt
gcloud --project=kubeflow-ci logging read --format="table(timestamp, resource.labels.container_name, textPayload)" \
	--freshness=24h \
	--order asc  \
	"resource.type=\"k8s_container\" metadata.userLabels.\"job-name\"=\"${JOB}\"  " > ${OUTFILE}

cat ${OUTFILE}
echo Logs written to ${OUTFILE}
