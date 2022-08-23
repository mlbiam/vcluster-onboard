FROM ubuntu:20.04

ADD install-vcluster.sh /root/install-vcluster.sh
RUN apt-get update && \
    apt-get install -y ca-certificates curl git && \
    curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && \
    apt-get install -y kubectl && \
    /root/install-vcluster.sh && \
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

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

