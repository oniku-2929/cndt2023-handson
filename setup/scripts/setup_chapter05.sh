#!/bin/bash

pushd $(dirname $0)/../..
SSH_CMD=$(make -s get-ssh-cmd)
WORKING_DIR="cndt2023-handson/chapter05_argocd"

$SSH_CMD -t "cd ${WORKING_DIR} && \
helmfile sync  -f helm/helmfile.yaml && \
kubectl get service,deployment  -n argo-cd && \
kubectl apply -f ingress/ingress.yaml && \
sleep 10 && \
kubectl -n argo-cd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d ; echo \
"

popd
