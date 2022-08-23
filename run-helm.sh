#!/bin/bash

export PATH=$PATH:~/.krew/bin



kubectl config set-cluster controlplane --server=https://kubernetes.default.svc:443 --certificate-authority=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
kubectl config set-credentials controlplane --token=/var/run/secrets/kubernetes.io/serviceaccount/token
kubectl config set-context controlplane --user=controlplane --user=controlplane

helm repo add tremolo $TREMOLO_HELM_REPO

helm repo update

helm install $HELM_DEPLOYMENT $HELM_CHART -n $TARGET_NAMESPACE -f $PATH_TO_VALUES