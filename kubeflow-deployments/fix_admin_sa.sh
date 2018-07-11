#!/bin/bash
#
# Script to deal with 
#https://github.com/kubeflow/kubeflow/issues/953
set -x
. env-kubeflow-jlewi.sh

NAME=${DEPLOYMENT_NAME}-admin
ADMIN_EMAIL=${NAME}@${PROJECT}.iam.gserviceaccount.com
K8S_NAMESPACE=kubeflow

declare -a roles=("compute.networkAdmin" "servicemanagement.admin" "source.admin")

# Now loop through the above array
for ROLE in "${roles[@]}"
do   
   gcloud projects remove-iam-policy-binding ${PROJECT} \
     --member serviceAccount:${ADMIN_EMAIL} \
     --role roles/${ROLE}
done

# Delete the service account
gcloud --project=${PROJECT} --quiet iam service-accounts delete ${ADMIN_EMAIL}

# Create the service account
gcloud --project=${PROJECT} --quiet iam service-accounts create ${NAME}

# Add policy bindings
for ROLE in "${roles[@]}"
do   
   gcloud projects add-iam-policy-binding ${PROJECT} \
     --member serviceAccount:${SA} \
     --role roles/${ROLE}
done

# Get a new service account key
rm -f ${ADMIN_EMAIL}.json 
gcloud --project=${PROJECT} iam service-accounts keys create ${ADMIN_EMAIL}.json --iam-account ${ADMIN_EMAIL}

# Delete and recreate the key
kubectl delete secret --namespace=${K8S_NAMESPACE} admin-gcp-sa
kubectl create secret generic --namespace=${K8S_NAMESPACE} admin-gcp-sa --from-file=admin-gcp-sa.json=./${ADMIN_EMAIL}.json

# Kick the envoy pods
kubectl -n ${K8S_NAMESPACE} delete pods -l service=envoy
