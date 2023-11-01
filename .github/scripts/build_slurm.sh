#!/bin/bash

# some tests
set -x

dnf -y install ${GITHUB_WORKSPACE}/pmix_rpms/*.rpm
          
echo "PMIX_RELTAG: ${SLURM_RELTAG}, PMIX_VERSION: ${SLURM_VERSION}"
mkdir -p ${HOME}/rpmbuild/SOURCES/
cp ${GITHUB_WORKSPACE}/slurm-*.tar.bz2 $HOME/rpmbuild/SOURCES/

set +x
