# Kustomize Image Transform

A simple experiment to test how the image transform works with kustomize.

Suppose you have

```
base
overlay
```

* And base changes the image "nginx"
* Then if overlay wants to transform the image it needs to refer to the image as set
  in base not the original value.