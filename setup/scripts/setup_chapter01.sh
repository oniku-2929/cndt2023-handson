#!/bin/bash

pushd $(dirname $0)/../..
SSH_CMD=$(make -s get-ssh-cmd)
WORKING_DIR="cndt2023-handson/chapter01_cluster-create"

$SSH_CMD -t "cd ${WORKING_DIR} && \
./install-tools.sh && \
sudo sysctl fs.inotify.max_user_watches=524288 && \
sudo sysctl fs.inotify.max_user_instances=512 && \
echo 'fs.inotify.max_user_watches = 524288' | sudo tee -a -i /etc/sysctl.conf && \
echo 'fs.inotify.max_user_instances = 512' | sudo tee -a -i /etc/sysctl.conf && \
sudo kind create cluster --config=kind-config.yaml \
"

$SSH_CMD -t "cd ${WORKING_DIR} && \
kind get kubeconfig && \
mkdir -p ~/.kube && \
sudo kind get kubeconfig > ~/.kube/config && \
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.0.0/config/crd/standard/gateway.networking.k8s.io_gatewayclasses.yaml && \
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.0.0/config/crd/standard/gateway.networking.k8s.io_gateways.yaml && \
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.0.0/config/crd/standard/gateway.networking.k8s.io_httproutes.yaml && \
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.0.0/config/crd/standard/gateway.networking.k8s.io_referencegrants.yaml && \
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.0.0/config/crd/experimental/gateway.networking.k8s.io_tlsroutes.yaml && \
helmfile sync -f helm/helmfile.yaml && \
echo waiting resources activation && sleep 30 && \
kubectl apply -f manifest/metallb.yaml && \
kubectl cluster-info && \
kubectl create namespace handson; \
kubectl apply -f manifest/app/serviceaccount.yaml -n handson -l color=blue && \
kubectl apply -f manifest/app/deployment.yaml -n handson -l color=blue && \
kubectl apply -f manifest/app/service.yaml -n handson && \
kubectl apply -f manifest/app/ingress.yaml -n handson \
"
popd

echo "access http://app.example.com"
