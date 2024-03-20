FROM ubuntu:22.04

ADD install-vcluster.sh /root/install-vcluster.sh
RUN apt-get update && \
    apt-get install -y ca-certificates curl git gnupg gnupg2 && \
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg && \
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && \
    apt-get install -y kubectl && \
    /root/install-vcluster.sh && \
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

RUN curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64 && \
    install -m 555 argocd-linux-amd64 /usr/local/bin/argocd && \
    rm argocd-linux-amd64

RUN mkdir -p /usr/local/openunison && \
    groupadd -r openunison -g 433 && \
    useradd -u 431 -r -g openunison -d /usr/local/openunison -s /sbin/nologin -c "OpenUnison Docker image user" openunison && \
    chown -R openunison:openunison /usr/local/openunison 

ADD install-krew.sh /usr/local/openunison/install-krew.sh
ADD onboard-cluster.sh /usr/local/openunison/onboard-cluster.sh
ADD onboard-vcluster-to-controlplane.sh /usr/local/openunison/onboard-vcluster-to-controlplane.sh
ADD run-helm.sh /usr/local/openunison/run-helm.sh
RUN chown -R openunison:openunison /usr/local/openunison

USER openunison

RUN /usr/local/openunison/install-krew.sh && \
    export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH" && \
    kubectl krew install ctx && \
    curl https://nexus.tremolo.io/repository/ouctl/ouctl.yaml > /usr/local/openunison/ouctl.yaml && \
    kubectl krew install --manifest=/usr/local/openunison/ouctl.yaml

