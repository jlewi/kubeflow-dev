#!/bin/bash
# Command doesn't appear to work; looks like it overloads some gcloud buffer.
gcloud container images add-tag --quiet \
	gcr.io/kubeflow-dev/kubeflow-kaggle-notebook@sha256:6a7e3423c3a8db391bc6d3e48356bbc43ed4126a400f3c80d3de005e7df80f99 \
	gcr.io/kubeflow-images-public/kaggle-notebook:v20180629