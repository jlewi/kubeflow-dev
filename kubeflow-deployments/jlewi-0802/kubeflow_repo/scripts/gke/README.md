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

To create GCFS

Edit gcfs.yaml to match your desirec configuration

  * Set zone
  * Set name
  * Set the value of parent to include your project e.g.

    ```
    projects/${PROJECT}/locations/${ZONE}
    ```

If you get the error

```
ERROR: (gcloud.deployment-manager.deployments.update) Error in Operation [operation-1533189457517-5726d7cfd19c9-e1b0b0b5-58ca11b8]: errors:
- code: RESOURCE_ERROR
  location: /deployments/jl-0801-b-gcfs/resources/filestore
  message: '{"ResourceType":"gcp-types/file-v1beta1:projects.locations.instances","ResourceErrorCode":"400","ResourceErrorMessage":{"code":400,"message":"network
    default is invalid; legacy networks are not supported.","status":"INVALID_ARGUMENT","statusMessage":"Bad
    Request","requestPath":"https://file.googleapis.com/v1beta1/projects/cloud-ml-dev/locations/us-central1-a/instances","httpMethod":"POST"}}'
    
```

```
gcloud deployment-manager --project=${PROJECT} deployments create ${DEPLOYMENT_NAME}-gcfs --config=gcfs.yaml
```
To configure GCFS

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