#!/bin/bash
pushd $(dirname $0)/../terraform
terraform init
INSTANCE_IP=$(terraform output -raw instance_ip)
echo "$INSTANCE_IP app.example.com" | tee -a /etc/hosts
echo "$INSTANCE_IP prometheus.example.com" | tee -a /etc/hosts
echo "$INSTANCE_IP grafana.example.com" | tee -a /etc/hosts
echo "$INSTANCE_IP jaeger.example.com" | tee -a /etc/hosts
echo "$INSTANCE_IP argocd.example.com" | tee -a /etc/hosts
echo "$INSTANCE_IP app.argocd.example.com" | tee -a /etc/hosts
echo "$INSTANCE_IP dev.kustomize.argocd.example.com" | tee -a /etc/hosts
echo "$INSTANCE_IP prd.kustomize.argocd.example.com" | tee -a /etc/hosts
echo "$INSTANCE_IP helm.argocd.example.com" | tee -a /etc/hosts
echo "$INSTANCE_IP app-preview.argocd.example.com" | tee -a /etc/hosts
echo "$INSTANCE_IP kiali.example.com" | tee -a /etc/hosts
echo "$INSTANCE_IP kiali-ambient.example.com" | tee -a /etc/hosts
echo "$INSTANCE_IP app.cilium.example.com" | tee -a /etc/hosts
echo "$INSTANCE_IP hubble.cilium.example.com" | tee -a /etc/hosts
popd
