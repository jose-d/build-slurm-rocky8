# build-slurm-rocky8
Build pmi-x and slurm rpms for Rocky8 with nvml support.

* changelog of upstream slurm project: https://github.com/SchedMD/slurm/blob/master/NEWS
* releases of openpmix upstream: https://github.com/openpmix/openpmix/releases

## Automatic build using Github Actions

* clone repository
* review and edit [workflow file](.github/workflows/build.yml), especially following vars need considering:
  * `IMG_REPO_URL` .. ghcr repository used as a cache for docker images used as build environment
  * `PMIX_VERSION` .. version of openPMIX used as build-dependency for Slurm
  * `NVML_VERSION` .. version of CUDA from where take the NVML from
  * `SLURM_VERSION` .. version of slurm to build

## Manual way using Apptainer(formerly known as Singularity)

credits:

* https://github.com/c3se/containers/tree/master/rpm-builds (the whole concept)
* advices of community at Easybuild Slack #scheduler channel
* presentations https://easybuild.io/tech-talks/ were used to clarify what is what in mpi-pmi(x)-slurm construct

#### (0) download source tarballs

(clone this repo)

`mkdir tarballs`

ensure in  `tarballs` have:

* `slurm-23.02.5.tar.bz2` - eg. from https://www.schedmd.com/downloads.php
* `pmix-4.2.6.tar.bz2` - eg. from https://github.com/openpmix/openpmix/releases

unpack all archives:

```
tar -xvf ./pmix*
tar -xvf ./slurm*
```

..and copy them to rpmbuild directory:

`mkdir -p $HOME/rpmbuild/SOURCES/`

```
cp tarballs/pmix-3.2.4.tar.bz2 $HOME/rpmbuild/SOURCES/
cp tarballs/slurm-*.bz2 $HOME/rpmbuild/SOURCES/
```


#### (1) build common apptainer image

(`sudo` needed here, expect size of ~ 300 MB)

```
sudo apptainer build ./base-rpmbuild-rocky8.sif ./base-rpmbuild-rocky8.def
```

#### (2) build apptainer build image for pmix

( no need of `sudo`, fakeroot works well, expect ~ 315 MB image)

_Note, that this container is without munge - which is apparently breaking interworking with slurm. (I'm not fully sure why)_

```
apptainer build --fakeroot ./build-pmix-rocky8.sif ./build-pmix-rocky8.def
```

#### (3) modify pmix release number in spec file

..in `tarballs/pmix-4.2.6/contrib/pmix.spec`.

so eg. `vim tarballs/pmix-4.2.6/contrib/pmix.spec`..

and around line 196 we can insert YYYYMMDDHHmm:

```
195 Version: 3.2.4
196 Release: 202303311242%{?dist}
197 License: BSD
```

#### (4) build pmix in apptainer

```
apptainer exec ./build-pmix-rocky8.sif rpmbuild --define 'build_all_in_one_rpm 0' --define 'configure_options --disable-per-user-config-files' -ba ./tarballs/pmix-*/contrib/pmix.spec
```

should produce rpms in `$HOME/rpmbuild/RPMS/x86_64/`. The next container build will pick them there automatically.


#### (5) build apptainer build image for slurm

(expect ~4.4 GB image size)

```
apptainer build --fakeroot ./build-slurm-rocky8.sif ./build-slurm-rocky8.def
```

#### (6) modify release number

in `tarballs/slurm-22.05.8/slurm.spec`, so eg.: `vim tarballs/slurm-22.05.8/slurm.spec` and around line `3`:

```
  2 Version:        22.05.8
  3 %define rel     202303311312
  4 Release:        %{rel}%{?dist}
```

and also replace the following `if` block with 

```
%global slurm_source_dir %{name}-%{version}
```

as we build from the upstream tarball..


#### (7) build slurm rpms in apptainer

```
apptainer exec ./build-slurm-rocky8.sif rpmbuild --define '_with_nvml --with-nvml=/usr/local/cuda/targets/x86_64-linux/' --with pam --with slurmrestd --with hwloc --with lua --with mysql --with numa --with pmix -ba ./tarballs/slurm-*/slurm.spec &> slurm_build.log
```

results should go into `$HOME/rpmbuild/RPMS/x86_64/`

#### (8) final notes

build results should look like 

```
$ ls -1 $HOME/rpmbuild/RPMS/x86_64/
pmix-4.2.6-202309111617.el8.x86_64.rpm
pmix-devel-4.2.6-202309111617.el8.x86_64.rpm
slurm-23.02.5-202309111636.el8.x86_64.rpm
slurm-contribs-23.02.5-202309111636.el8.x86_64.rpm
slurm-devel-23.02.5-202309111636.el8.x86_64.rpm
slurm-example-configs-23.02.5-202309111636.el8.x86_64.rpm
slurm-libpmi-23.02.5-202309111636.el8.x86_64.rpm
slurm-openlava-23.02.5-202309111636.el8.x86_64.rpm
slurm-pam_slurm-23.02.5-202309111636.el8.x86_64.rpm
slurm-perlapi-23.02.5-202309111636.el8.x86_64.rpm
slurm-slurmctld-23.02.5-202309111636.el8.x86_64.rpm
slurm-slurmd-23.02.5-202309111636.el8.x86_64.rpm
slurm-slurmdbd-23.02.5-202309111636.el8.x86_64.rpm
slurm-slurmrestd-23.02.5-202309111636.el8.x86_64.rpm
slurm-torque-23.02.5-202309111636.el8.x86_64.rpm
$
```

Note, that slurm needs `libpmix.so`, which is curiously provided by `pmix-devel` rpm and not `pmix` as one would expect. So make sure that both rpms are installed at slurm server, submit, and execute nodes.
