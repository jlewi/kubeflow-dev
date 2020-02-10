#!/bin/bash
#
# A helper script to rerun the sequence of commands
set -ex
kustomize build ~/git_kubeflow-testing/apps-cd/pipelines/base/ | kubectl apply -f -
kubectl create -f  ~/git_kubeflow-testing/apps-cd/runs/profile_controller_v1795828.yaml 
kubectl get pipelineruns --sort-by=.metadata.creationTimestamp
LASTRUN=$(kubectl get pipelineruns --sort-by=.metadata.creationTimestamp -o jsonpath="{.items[-1:].metadata.name}")
echo LASTRUN=${LASTRUN}


