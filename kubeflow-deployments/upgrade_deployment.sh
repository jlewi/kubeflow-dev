#!/bin/bash
#
# Upgrade a Kubeflow app to a given version.
#

set -ex
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd ${DIR}/ks-app

# Run the upgrade script.
# TODO(jlewi): We might want to specify the registry version.
~/git_kubeflow/scripts/upgrade_ks_app.py 

# Regenerate the core component
ks component rm kubeflow-core
ks generate kubeflow-core kubeflow-core
ks param set kubeflow-core jupyterHubAuthenticator iap
ks param set kubeflow-core jupyterNotebookPVCMount /home/jovyan
