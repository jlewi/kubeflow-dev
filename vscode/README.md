# vscode

Running vscode on Kubeflow

The server is https://coder.com/

Looks like there is an issue with running it behind a reverse proxy
https://github.com/cdr/code-server/issues/670

https://binal.pub/2019/04/running-vscode-in-docker/
https://github.com/caesarnine/data-science-docker-vscode-template

```
https://localhost:8080/
```

Works with kubectl port-forward but not with ambassador proxy; because of https://github.com/cdr/code-server/issues/670