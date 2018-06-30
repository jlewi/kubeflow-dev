# Storing Model Information In Model DB

This is an experiment to see if we can take advantage of Model DB (which is part of Katib) to track models.

We take advantage of ModelDB's Light APi
https://github.com/mitdbg/modeldb/blob/master/client/python/light_api.md

# Instructions

Install the ModelDB PIP package

```
pip install modeldb
```

Port forward 6543 to the modeldb pod

```
kubectl port-forward `kubectl get pods --selector=app=modeldb,component=backend -o jsonpath='{.items[0].metadata.name}'` 6543:6543

```