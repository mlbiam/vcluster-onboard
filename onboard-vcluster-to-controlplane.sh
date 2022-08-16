#!/bin/bash

export PATH=$PATH:~/.krew/bin

export VCLUSTER_CTX=$(kubectl ctx)

echo "VCluster context: $VCLUSTER_CTX\n"

helm repo add tremolo $TREMOLO_HELM_REPO
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm repo update

kubectl ctx

kubectl config set-cluster controlplane --server=https://kubernetes.default.svc:443 --certificate-authority=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
kubectl config set-credentials controlplane --token=/var/run/secrets/kubernetes.io/serviceaccount/token
kubectl config set-context controlplane --user=controlplane --user=controlplane

kubectl ctx $VCLUSTER_CTX

kubectl ctx

#kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.5.0/aio/deploy/recommended.yaml
helm install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --set settings.clusterName=vcluster-blog -n kubernetes-dashboard

kubectl ctx controlplane

kubectl ouctl install-satelite -r cluster-role-bindings=tremolo/openunison-vcluster-admins /etc/openunison/satelite.yaml controlplane $VCLUSTER_CTX
