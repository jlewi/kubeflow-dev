# vscode

Kubernetes resources to run VS Code Server

This is possible because of [coder.com](https://coder.com/) which has published
a remote server for Visual Studio Code.

Unfortunately, I haven't been able to get this working behind ISTIO (1.4)

  * So for now you will need to use `kubectl port-forward`.
  * TODO(jlewi): Try using a Deployment instead of statefulset?
  * With ISTIO i'm getting upstream/disconnect errors 
  * https://github.com/cdr/code-server/issues/670 related to reverse proxies


## Instructions

1. List the setters

   ```
   kpt cfg list-setters .
   ```

1. Set all the setters

   ```
   kpt cfg set . ...
   ```

1. Deploy it

   ```
   make apply
   ```

1. Port-forward to the service

   ```
   kubectl port-forward service service/${NAME} 8080:80
   ```
## ISTIO

Notes about trying to make it work over istio

* codeserver has a healthcheck on "/healthz"

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
