#!/bin/bash

pushd $(dirname $0)/../..
SSH_CMD=$(make -s get-ssh-cmd)
WORKING_DIR="cndt2023-handson/chapter02_prometheus"

$SSH_CMD -t "cd ${WORKING_DIR} && \
helmfile sync -f helm/helmfile.yaml && \
kubectl get pods -n prometheus && \
kubectl apply -f ingress.yaml && \
kubectl apply -f manifests/ingress-nginx-servicemonitor.yaml \
"

popd
