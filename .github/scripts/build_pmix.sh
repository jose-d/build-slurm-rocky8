#!/bin/bash

# print input vars
echo "PMIX_RELTAG: ${PMIX_RELTAG}, PMIX_VERSION: ${PMIX_VERSION}"

# enable shell debug
set -x

# install deps
# N/A

# mkdir for rpmbuild and copy tarball there
mkdir -p "${HOME}/rpmbuild/SOURCES/"
cp  ${GITHUB_WORKSPACE}/pmix-*.tar.bz2 ${HOME}/rpmbuild/SOURCES/

# dump rpmlist for possible forensic
rpm -qa | sort > "${GITHUB_WORKSPACE}/image_pmix_rpms.txt"

# do rpmbuild
rpmbuild --define 'build_all_in_one_rpm 0' \
         --define 'configure_options --disable-per-user-config-files' \
         -ba ./pmix-*/contrib/pmix.spec &> ${GITHUB_WORKSPACE}/pmix_build.log

mkdir "${GITHUB_WORKSPACE}/rpms"
cp ${HOME}/rpmbuild/RPMS/x86_64/*.rpm ${GITHUB_WORKSPACE}/rpms/
