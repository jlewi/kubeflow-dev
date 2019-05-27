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

Now when I start it with

```
code-server --allow-http --no-auth --data-dir /home/jovyan/data
```

```
curl http://localhost:8443
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Error</title>
</head>
<body>
<pre>Cannot GET /</pre>
</body>
</html>
```

* Happens even if I run from within the pod.
* The thing that changed is I'm user jovyan now; I think it was working when I was running as root.
  * Seems to work as root; takes some time to load.