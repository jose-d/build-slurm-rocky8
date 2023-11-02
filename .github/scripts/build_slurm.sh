#!/bin/bash

# some tests
set -x

dnf -y install ${GITHUB_WORKSPACE}/pmix_rpms/*.rpm
          
echo "PMIX_RELTAG: ${SLURM_RELTAG}, PMIX_VERSION: ${SLURM_VERSION}"
mkdir -p "${HOME}/rpmbuild/SOURCES/"
cp ${GITHUB_WORKSPACE}/slurm-*.tar.bz2 $HOME/rpmbuild/SOURCES/


rpmbuild --define '_with_nvml --with-nvml=/usr/local/cuda/targets/x86_64-linux/' \
          --with pam \
          --with slurmrestd \
          --with hwloc \
          --with lua \
          --with mysql \
          --with numa \
          --with pmix \
          -ba ./slurm-*/slurm.spec

mkdir ${GITHUB_WORKSPACE}/rpms
cp ${HOME}/rpmbuild/RPMS/x86_64/slurm-*.rpm ${GITHUB_WORKSPACE}/rpms/

set +x
