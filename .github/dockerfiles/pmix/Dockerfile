ARG BASE_IMAGE=None
FROM $BASE_IMAGE

RUN dnf -y update && \
    dnf install -y zlib-devel hwloc-devel libevent-devel python3-devel jansson-devel && \
    dnf clean all

RUN python3 -m pip install --no-cache-dir sphinx