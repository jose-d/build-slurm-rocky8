FROM josed/build_slurm_base:latest

ENV CUDA_VERSION=12-2

RUN dnf upgrade -y
RUN dnf install -y epel-release
RUN dnf install -y libjwt-devel zlib-devel munge-devel pam-devel perl-ExtUtils-MakeMaker python3 readline-devel mariadb-devel numactl-devel libevent-devel hwloc-devel lua-devel json-c-devel pam-devel libX11-devel libssh2-devel libyaml-devel libcurl-devel lz4-devel freeipmi-devel http-parser-devel dbus-devel
RUN dnf install -y createrepo_c gtk2-devel

RUN dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel8/x86_64/cuda-rhel8.repo
RUN dnf clean all
RUN dnf -y install cuda-nvml-devel-${CUDA_VERSION} cuda-${CUDA_VERSION}

CMD ["echo", "Slurm_build_image"]
