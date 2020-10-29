# This is a custom jupyter image
#
# It includes additional dependencies like
# 1. Update kfp client
# 2. coder https://coder.com/ so we can run coder in the pod and use it as en editor
#
# The motivation for using the same image as the jupyter image is so that the set
# of python liraries is the same for intellisense.
ARG BASE_IMAGE=tensorflow/tensorflow:2.2.0-jupyter

FROM $BASE_IMAGE

# TODO: User should be refactored instead of hard coded jovyan

USER root

ENV DEBIAN_FRONTEND noninteractive

ENV NB_USER jovyan

ENV NB_UID 1000
ENV HOME /home/$NB_USER
ENV NB_PREFIX /
ENV PATH $HOME/.local/bin:$PATH

# Use bash instead of sh
SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get install -yq --no-install-recommends \
  apt-transport-https \
  build-essential \
  bzip2 \
  ca-certificates \
  curl \
  g++ \
  git \
  gnupg \
  graphviz \
  locales \
  lsb-release \
  openssh-client \
  sudo \
  unzip \
  vim \
  wget \
  zip \
  emacs \
  python3-pip \
  python3-dev \
  python3-setuptools \
  && apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Install Nodejs for jupyterlab-manager
RUN curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
RUN apt-get update && apt-get install -yq --no-install-recommends \
  nodejs \
  && apt-get clean && \
  rm -rf /var/lib/apt/lists/*

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Create NB_USER user with UID=1000 and in the 'users' group
# but allow for non-initial launches of the notebook to have
# $HOME provided by the contents of a PV
RUN useradd -M -s /bin/bash -N -u $NB_UID $NB_USER && \
    chown -R ${NB_USER}:users /usr/local/bin && \
    mkdir -p $HOME && \
    chown -R ${NB_USER}:users ${HOME}

RUN export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
    echo "deb https://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" > /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-get update && \
    apt-get install -y google-cloud-sdk kubectl

# Install Tini - used as entrypoint for container
RUN cd /tmp && \
    wget --quiet https://github.com/krallin/tini/releases/download/v0.18.0/tini && \
    echo "12d20136605531b09a2c2dac02ccee85e1b874eb322ef6baf7561cd93f93c855 *tini" | sha256sum -c - && \
    mv tini /usr/local/bin/tini && \
    chmod +x /usr/local/bin/tini


USER root

#*************************************************************************************************************
# Install VSCode
#************************************************************************************************************

# Install coder
# download the coder binary, untar it, and allow it to be executed
RUN curl -LO https://github.com/codercom/code-server/releases/download/1.408-vsc1.32.0/code-server1.408-vsc1.32.0-linux-x64.tar.gz \
 && tar -xzvf code-server1.408-vsc1.32.0-linux-x64.tar.gz && \
 mv code-server1.408-vsc1.32.0-linux-x64 /usr/local/ && \
 ln -sf /usr/local/code-server1.408-vsc1.32.0-linux-x64/code-server /usr/local/bin/code-server && \
 chmod +x /usr/local/code-server1.408-vsc1.32.0-linux-x64/code-server
 
COPY requirements.txt .
RUN pip3 --no-cache-dir install -r requirements.txt

USER jovyan