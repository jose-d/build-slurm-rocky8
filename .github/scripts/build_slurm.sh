#!/bin/bash

# print input vars
echo "PMIX_RELTAG: ${SLURM_RELTAG}, PMIX_VERSION: ${SLURM_VERSION}"

# enable shell debug
set -x

# install deps
dnf -y install ${GITHUB_WORKSPACE}/pmix_rpms/*.rpm

# mkdir for rpmbuild and copy tarball there
mkdir -p "${HOME}/rpmbuild/SOURCES/"
cp ${GITHUB_WORKSPACE}/slurm-*.tar.bz2 $HOME/rpmbuild/SOURCES/

# do rpmbuild
rpmbuild --define '_with_nvml --with-nvml=/usr/local/cuda/targets/x86_64-linux/' \
          --with pam \
          --with slurmrestd \
          --with hwloc \
          --with lua \
          --with mysql \
          --with numa \
          --with pmix \
          -ba ./slurm-*/slurm.spec

mkdir "${GITHUB_WORKSPACE}/rpms"
cp ${HOME}/rpmbuild/RPMS/x86_64/slurm-*.rpm "${GITHUB_WORKSPACE}/rpms/"

set +x
