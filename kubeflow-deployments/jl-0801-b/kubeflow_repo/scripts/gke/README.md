# Instructions

This is a temporary place holder for instructions. These instructions should migrate
to the website. However, our website docs are currently describing 0.2 and these instructions
apply to 0.3.

To create a deployment

```
export DEPLOYMENT_NAME=<your deployment>
export KUBEFLOW_VERSION=<version>
mkdir -p ${DEPLOYMENT_NAME}
cd ${DEPLOYMENT_NAME}
curl -o deploy.sh https://raw.githubusercontent.com/kubeflow/kubeflow/v${KUBEFLOW_VERSION}/scripts/gke/deploy.sh 
deploy.sh setup_project
deploy.sh configure
deploy.sh update
```

To config GCFS

```
. env.sh
cd ${DEPLOYMENT_NAME}/${KUBEFLOW_KS_DIR}
ks generate google-cloud-filestore-pv google-cloud-filestore-pv --name="kubeflow-gcfs" \
   --storageCapacity="${GCFS_STORAGE}" \
   --serverIP="${GCFS_INSTANCE_IP_ADDRESS}"
ks param set jupyterhub disks "kubeflow-gcfs"  
ks apply default -c google-cloud-filestore-pv
ks apply default -c jupyterhub
```