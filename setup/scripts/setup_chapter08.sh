#!/bin/bash

pushd $(dirname $0)/../..
SSH_CMD=$(make -s get-ssh-cmd)
WORKING_DIR="cndt2023-handson/chapter08_argo-rollouts"

$SSH_CMD -t "cd ${WORKING_DIR} && \
kubectl apply -n argo-cd -f https://raw.githubusercontent.com/argoproj-labs/rollout-extension/v0.2.1/manifests/install.yaml && \
helmfile sync  -f helm/helmfile.yaml \
"

popd
