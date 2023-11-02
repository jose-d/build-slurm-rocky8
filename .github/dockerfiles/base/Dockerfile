FROM rockylinux:8

RUN dnf update -y && \
    dnf install -y dnf-plugins-core && \
    dnf config-manager --set-enabled powertools && \
    dnf install -y rpm-build automake autoconf libtool make pkg-config less vim flex bison doxygen cmake bash-doc which wget && \
    dnf clean all
