#!/bin/bash

# some tests
which gcc
cat /identity
          
echo "PMIX_RELTAG: ${PMIX_RELTAG}, PMIX_VERSION: ${PMIX_VERSION}"

mkdir -p ${HOME}/rpmbuild/SOURCES/
wget --quiet https://github.com/openpmix/openpmix/releases/download/v${PMIX_VERSION}/pmix-${PMIX_VERSION}.tar.bz2
tar -xf ./pmix*
cp pmix-*.tar.bz2 ${HOME}/rpmbuild/SOURCES/
sed -i "s/^Release.*$/Release: ${PMIX_RELTAG}%{?dist}/g" pmix-*/contrib/pmix.spec

cat pmix-*/contrib/pmix.spec
          
rpmbuild --define 'build_all_in_one_rpm 0' --define 'configure_options --disable-per-user-config-files' -ba ./pmix-*/contrib/pmix.spec
mkdir ${GITHUB_WORKSPACE}/rpms
cp ${HOME}/rpmbuild/RPMS/x86_64/pmix-*.rpm ${GITHUB_WORKSPACE}/rpms/
