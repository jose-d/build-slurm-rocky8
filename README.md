# build-slurm-rocky8
Build slurm rpms at Rocky8 with cuda support.

credits:
strongly inspired by https://github.com/c3se/containers/tree/master/rpm-builds

#### (0) download source tarballs

ensure in  `tarballs` have:

* `slurm-22.05.8.tar.bz2` - eg. from https://www.schedmd.com/downloads.php
* `pmix-3.2.4.tar.bz2` - eg. from https://github.com/openpmix/openpmix/releases

unpack all archives:

```
tar -xvf ./pmix-3.2.4.tar.bz2
tar -xvf ./slurm-22.05.8.tar.bz2
```

..and copy them to rpmbuild directory:

```
cp tarballs/pmix-3.2.4.tar.bz2 $HOME/rpmbuild/SOURCES/
cp tarballs/slurm-22.05.8.tar.bz2 $HOME/rpmbuild/SOURCES/
```


#### (1) build common apptainer image

(`sudo` needed here, expect size of ~ 300 MB)

```
sudo apptainer build ./base-rpmbuild-rocky86.sif ./base-rpmbuild-rocky86.def
```

#### (2) build apptainer build image for pmix

( no need of `sudo`, fakeroot works well, expect ~ 315 MB image)

```
apptainer build --fakeroot ./build-pmix-rocky86.sif ./build-pmix-rocky86.def
```

#### (3) modify pmix release number in spec file

..in `tarballs/pmix-3.2.4/contrib/pmix.spec`.

so eg. `vim tarballs/pmix-3.2.4/contrib/pmix.spec`..

and around line 196 we can insert YYYYMMDDHHmm:

```
195 Version: 3.2.4
196 Release: 202303311242%{?dist}
197 License: BSD
```

#### (4) build pmix in apptainer

```
apptainer exec ./build-pmix-rocky86.sif rpmbuild --define 'build_all_in_one_rpm 0' --define 'configure_options --disable-per-user-config-files' -ba ./tarballs/pmix-3.2.4/contrib/pmix.spec
```

should produce rpms in `$HOME/rpmbuild/RPMS/x86_64/`. The next container build will pick them there automatically.


#### (5) build apptainer build image for slurm

(expect ~4.4 GB image size)

```
apptainer build --fakeroot ./build-slurm-rocky86.sif ./build-slurm-rocky86.def
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
apptainer exec ./build-slurm-rocky86.sif rpmbuild --define '_with_nvml --with-nvml=/usr/local/cuda/targets/x86_64-linux/' --with pam --with slurmrestd --with hwloc --with lua --with mysql --with numa --with pmix -ba ./tarballs/slurm-22.05.8/slurm.spec &> slurm_build.log
```

results should go into `$HOME/rpmbuild/RPMS/x86_64/`

#### (8) final notes

build results should look like 

```
$ ls -1 $HOME/rpmbuild/RPMS/x86_64/
pmix-3.2.4-202303311352.el8.x86_64.rpm
pmix-devel-3.2.4-202303311352.el8.x86_64.rpm
pmix-libpmi-3.2.4-202303311352.el8.x86_64.rpm
pmix-libpmi-devel-3.2.4-202303311352.el8.x86_64.rpm
slurm-22.05.8-202303311409.el8.x86_64.rpm
slurm-contribs-22.05.8-202303311409.el8.x86_64.rpm
slurm-devel-22.05.8-202303311409.el8.x86_64.rpm
slurm-example-configs-22.05.8-202303311409.el8.x86_64.rpm
slurm-libpmi-22.05.8-202303311409.el8.x86_64.rpm
slurm-openlava-22.05.8-202303311409.el8.x86_64.rpm
slurm-pam_slurm-22.05.8-202303311409.el8.x86_64.rpm
slurm-perlapi-22.05.8-202303311409.el8.x86_64.rpm
slurm-slurmctld-22.05.8-202303311409.el8.x86_64.rpm
slurm-slurmd-22.05.8-202303311409.el8.x86_64.rpm
slurm-slurmdbd-22.05.8-202303311409.el8.x86_64.rpm
slurm-slurmrestd-22.05.8-202303311409.el8.x86_64.rpm
slurm-torque-22.05.8-202303311409.el8.x86_64.rpm
$
```

Note, that slurm needs `libpmix.so`, which is curiously provided by `pmix-devel` rpm and not `pmix` as one would expect. So make sure that both rpms are installed at slurm server, submit, and execute nodes.
