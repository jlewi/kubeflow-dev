# vscode

You can run Microsoft's Visual Studio Code in a side car of your Jupyter pods.

This is possible because of [coder.com](https://coder.com/) which has published
a remote server for Visual Studio Code.

This makes it easy to edit code using a full IDE and then run that code from within your
Jupyter notebook.

Unfortunately, due to https://github.com/cdr/code-server/issues/670 code-server
doesn't work behind a reverse proxy yet. So you will need to use `kubectl port-forward`.


## Instructions

1. Build a docker image containing Visual Studio code server.

   ```
   IMAGE=<URL for your code-server image>
   make IMG=${IMAGE} push
   ```

1. Follow the Kubeflow [instructions](https://www.kubeflow.org/docs/notebooks/setup/) to run a notebook

1. Get the spec for your notebook

   ```
   kubectl get notebooks ${NOTEBOOK} > ${NOTEBOOK}.yaml
   ```
Looks like there is an issue with running it behind a reverse proxy

1. Add a side car to the pod template spec to run vscode

   ```
   ...
   spec:
      containers:
      ...
      - env: []
        command:
          - code-server
          - --allow-http
          - --no-auth
          - --data-dir=/home/jovyan/data
        image: ${VSCODE-IMAGE}
        name: vscode
        resources:
          limits:
            cpu: 8
            memory: 16Gi
          requests:
            cpu: 1
            memory: 1Gi    
        volumeMounts:
        - mountPath: /home/jovyan
          name: ${PVC-NAME}
   ...
   ```

   * Replace `${VCODE-IMAGE}` with the URL of the docker image you built in the previous step
   * Replace `${PVC-NAME}` with the name of the PVC for your home directory
   * The home directory is shared between the vscode container and the jupyter container.
     * This ensures you can edit files with vscode and then run them inside jupyter

1. Connect to vscode using port-forwarding

   ```
   kubectl port-forward ${NOTEBOOK}-0 8443:8443
   ```

1. Open http://localhost:8443 to connect

   * **Note** The first time you open it seems to take several minutes to fully load


## Known issues

* Connection seems to be flaky
  
  * Sometimes when I connect get a black screen; have to hit refresh multiple times before anything shows up

* code-server logs show the following

  ```
  ERROR proxy 17 disposed too early {"type":"undefined","proxyId":17}
  ERROR proxy 17 disposed too early {"type":"undefined","proxyId":17}
  ERROR proxy 13 disposed too early {"type":"undefined","proxyId":13}
  ERROR proxy 0 disposed too early {"type":"undefined","proxyId":0}
  ERROR proxy 0 disposed too early {"type":"undefined","proxyId":0}
  INFO  WebSocket opened / {"client":9,"ip":"127.0.0.1"}
  ```

## References

* https://github.com/cdr/code-server/issues/670 - Issue with code server and reverse proxy.
* https://coder.com/
* https://binal.pub/2019/04/running-vscode-in-docker/
* https://github.com/caesarnine/data-science-docker-vscode-template
