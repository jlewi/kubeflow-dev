#!/bin/bash
STORAGE_SIZE=100
BUCKET_NAME=cloud-ml-dev-jlewi-pachyderm



pachctl deploy --namespace=pachyderm google ${BUCKET_NAME} ${STORAGE_SIZE} \
	/home/jlewi/secrets/jlewi-pachyderm@cloud-ml-dev.iam.gserviceaccount.json  \
	--dynamic-etcd-nodes=1
