#!/bin/bash

# some tests
set -x
          
echo "PMIX_RELTAG: ${SLURM_RELTAG}, PMIX_VERSION: ${SLURM_VERSION}"
mkdir -p ${HOME}/rpmbuild/SOURCES/
