# test
FROM rockylinux:8

RUN dnf install -y dnf-plugins-core
RUN dnf config-manager --set-enabled powertools
RUN dnf install -y rpm-build automake autoconf libtool make pkg-config less vim flex bison doxygen cmake bash-doc which wget

CMD ["echo", "Brekekeke"]
