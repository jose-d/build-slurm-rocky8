ARG BASE_IMAGE=None
FROM $BASE_IMAGE

ARG NVML_VERSION

RUN echo "In Docker: NVML_VERSION: $NVML_VERSION"

RUN dnf upgrade -y && \
    dnf install -y epel-release && \
    dnf install -y libjwt-devel zlib-devel munge-devel pam-devel perl-ExtUtils-MakeMaker python3 readline-devel mariadb-devel numactl-devel libevent-devel hwloc-devel lua-devel json-c-devel pam-devel libX11-devel libssh2-devel libyaml-devel libcurl-devel lz4-devel freeipmi-devel http-parser-devel dbus-devel && \
    dnf install -y createrepo_c gtk2-devel && \
    dnf clean all

# we go with precompiled nvidia-driver to save time..
RUN dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel8/x86_64/cuda-rhel8.repo && \
    dnf -y module install nvidia-driver:560 && \
    dnf clean all && \
    dnf -y install --nobest cuda-nvml-devel-$NVML_VERSION cuda-$NVML_VERSION && \
    dnf clean all
