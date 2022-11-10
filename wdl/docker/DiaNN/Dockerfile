FROM bitnami/minideb:latest

ARG DIANN_VERSION=1.8

RUN apt-get update && \
    apt-get install -y wget libgomp1

RUN mkdir -p /data /code && \
    cd /code && \
    wget https://github.com/vdemichev/DiaNN/releases/download/${DIANN_VERSION}/diann_${DIANN_VERSION}.deb && \
    dpkg -i diann_${DIANN_VERSION}.deb && \
    ln -s /usr/diann/${DIANN_VERSION}/diann-${DIANN_VERSION} /usr/bin/diann

WORKDIR /data

