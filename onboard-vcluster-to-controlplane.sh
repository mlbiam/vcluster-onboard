#!/bin/bash

export PATH=$PATH:~/.krew/bin

export VCLUSTER_CTX=$(kubectl ctx)

echo "VCluster context: $VCLUSTER_CTX"

helm repo add tremolo $TREMOLO_HELM_REPO
helm repo add kubernetes-dashboard $K8S_DASHBOARD_HELM_REPO
helm repo update

kubectl ctx

kubectl config set-cluster controlplane --server=https://kubernetes.default.svc:443 --certificate-authority=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
kubectl config set-credentials controlplane --token=/var/run/secrets/kubernetes.io/serviceaccount/token
kubectl config set-context controlplane --user=controlplane --user=controlplane

kubectl ctx $VCLUSTER_CTX

kubectl ctx

kubectl create ns kubernetes-dashboard
helm install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard  --version 6.0.8  --set settings.clusterName=$VCLUSTER_LABEL --set settings.itemsPerPage=15 -n kubernetes-dashboard


if [ -v CA_CRT ]; then
    mkdir -p /tmp/cert-secret
    echo -n $CA_CRT | base64 -d > /tmp/cert-secret/cert.pem
    kubectl create ns openunison
    kubectl create secret generic unison-ca --from-file=/tmp/cert-secret -n openunison
else
    echo "No CA Cert"
fi

kubectl ctx controlplane

kubectl ouctl install-satelite -r cluster-role-bindings=tremolo/openunison-vcluster-admins /etc/openunison/satelite.yaml controlplane $VCLUSTER_CTX
