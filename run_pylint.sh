#!/bin/bash
set -ex
PYTHONPATH=~/git_kubeflow_testing/py

python -m kubeflow.testing.py_checks lint
