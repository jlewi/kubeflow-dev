#!/bin/bash
set -ex 
.  env-kubeflow-jlewi.sh

gcloud deployment-manager --project=${PROJECT} deployments delete ${DEPLOYMENT}

# TODO(jlewi): Delete service accounts and other resources to cleanup a failed
# deployment manager delete.