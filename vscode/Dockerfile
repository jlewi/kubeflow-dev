# This is a custom jupyter image
#
# It includes additional dependencies like
# 1. Update kfp client
# 2. coder https://coder.com/ so we can run coder in the pod and use it as en editor
#
# The motivation for using the same image as the jupyter image is so that the set
# of python liraries is the same for intellisense.
FROM gcr.io/kubeflow-images-public/tensorflow-1.12.0-notebook-cpu:v0.5.0

USER root


 # Install coder
 # download the coder binary, untar it, and allow it to be executed
 RUN curl -LO https://github.com/codercom/code-server/releases/download/1.408-vsc1.32.0/code-server1.408-vsc1.32.0-linux-x64.tar.gz \
     && tar -xzvf code-server1.408-vsc1.32.0-linux-x64.tar.gz && \
     mv code-server1.408-vsc1.32.0-linux-x64 /usr/local/ && \
     ln -sf /usr/local/code-server1.408-vsc1.32.0-linux-x64/code-server /usr/local/bin/code-server && \
     chmod +x /usr/local/code-server1.408-vsc1.32.0-linux-x64/code-server
 
COPY requirements.txt .
RUN pip3 --no-cache-dir install -r requirements.txt

RUN apt-get update -y
RUN apt-get install -y emacs

RUN pip3 install https://storage.googleapis.com/ml-pipeline/release/0.1.20/kfp.tar.gz

# Checkout kubeflow/testing because we use some of its utilities
RUN mkdir -p /src/kubeflow && \
    cd /src/kubeflow && \
    git clone https://github.com/kubeflow/testing.git testing

# Install the hub CLI for git
RUN cd /tmp && \
    curl -LO  https://github.com/github/hub/releases/download/v2.11.2/hub-linux-amd64-2.11.2.tgz && \
    tar -xvf hub-linux-amd64-2.11.2.tgz && \
    mv hub-linux-amd64-2.11.2 /usr/local && \
    ln -sf /usr/local/hub-linux-amd64-2.11.2/bin/hub /usr/local/bin/hub

 USER jovyan