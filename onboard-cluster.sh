#!/bin/bash

export PATH=$PATH:~/.krew/bin

if [ -v ONBOARD_SCRIPT ];then
    echo "Running onboard script $ONBOARD_SCRIPT"
else
    export ONBOARD_SCRIPT="/usr/local/openunison/onboard-vcluster-to-controlplane.sh"
    echo "Running onboard script $ONBOARD_SCRIPT"
fi

kubectl config set-cluster controlplane --server=https://kubernetes.default.svc:443 --certificate-authority=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
kubectl config set-credentials controlplane --token=/var/run/secrets/kubernetes.io/serviceaccount/token
kubectl config set-context controlplane --user=controlplane --user=controlplane

vcluster connect $VCLUSTER_NAME  -n $VCLUSTER_NAMESPACE -- $ONBOARD_SCRIPT
