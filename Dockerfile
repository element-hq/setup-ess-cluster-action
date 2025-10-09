# syntax=docker/dockerfile:1
# Copyright 2024-2025 New Vector Ltd
#
# SPDX-License-Identifier: LicenseRef-Element-Commercial
FROM python:3.12-slim-bookworm

ARG HELM_VERSION=3.18.6
ENV KIND_VERSION=v0.29.0
ARG KUBECONFORM_VERSION=0.6.7
ENV KUBECTL_VERSION=v1.32.2
ARG POETRY_VERSION=1.8.5
ARG YQ_VERSION=4.45.1
ARG CRANE_VERSION=0.20.3
ARG ORAS_VERSION=1.2.2

ARG PIPX_BIN_DIR=/usr/local/bin

RUN <<EOT bash
  set -eux
  apt -y update
  apt -y --no-install-recommends install \
    ca-certificates \
    curl \
    git \
    pipx \
    shellcheck \
    skopeo \
    jq

  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc

  # docker
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null
  apt-get -y update
  apt-get -y --no-install-recommends install docker-ce docker-ce-cli docker-buildx-plugin

  rm -rf /var/lib/apt/lists/*
  python3 --version
  shellcheck --version
  docker --version

  # Helm
  mkdir helm && pushd helm
  curl -L https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz | tar -xzv
  install -m u=rwx,g=rx,o=rx linux-amd64/helm /usr/local/bin/helm
  popd && rm -rf helm
  helm version

  # Kubeconform
  mkdir kubeconform && pushd kubeconform
  curl -L https://github.com/yannh/kubeconform/releases/download/v${KUBECONFORM_VERSION}/kubeconform-linux-amd64.tar.gz | tar -xzv
  install -m u=rwx,g=rx,o=rx kubeconform /usr/local/bin/kubeconform
  popd && rm -rf kubeconform
  kubeconform -v

  # Kind
  curl -L -o kind-linux-amd64 https://github.com/kubernetes-sigs/kind/releases/download/${KIND_VERSION}/kind-linux-amd64
  curl -L -o kind-linux-amd64.sha256sum https://github.com/kubernetes-sigs/kind/releases/download/${KIND_VERSION}/kind-linux-amd64.sha256sum
  sha256sum -c --status kind-linux-amd64.sha256sum
  rm kind-linux-amd64.sha256sum
  mv kind-linux-amd64 /usr/local/bin/kind
  chmod +x /usr/local/bin/kind
  kind --version

  # kubectl
  curl -L -o /usr/local/bin/kubectl https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl
  chmod +x /usr/local/bin/kubectl
  kubectl version --client
  # yq
  curl -L -o /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64 && chmod +x /usr/local/bin/yq
  yq --version

  # crane
  mkdir crane && pushd crane
  curl -L https://github.com/google/go-containerregistry/releases/download/v${CRANE_VERSION}/go-containerregistry_Linux_x86_64.tar.gz | tar -xzv crane
  install -m u=rwx,g=rx,o=rx crane /usr/local/bin/crane
  popd && rm -rf crane
  crane version

  # oras
  mkdir oras && pushd oras
  curl -L https://github.com/oras-project/oras/releases/download/v${ORAS_VERSION}/oras_${ORAS_VERSION}_linux_amd64.tar.gz | tar -xzv oras
  install -m u=rwx,g=rx,o=rx oras /usr/local/bin/
  popd && rm -rf crane
  oras version

  useradd -rm -d /home/runner -s /bin/bash -u 1001 runner
  python3 -m pip install --user pipx
  python3 -m pipx ensurepath

  python3 -m pipx install --global poetry==${POETRY_VERSION}
EOT

# Install pipx in user 1001 used by runAsUser of the github pod template
USER runner

RUN <<EOT bash
  ls -l /usr/local/bin
  pipx ensurepath
  source ~/.bashrc
  poetry --version
EOT
