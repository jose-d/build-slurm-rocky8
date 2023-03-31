# build-slurm-rocky8
Build slurm rpms at Rocky8 with cuda support.

credits:
strongly inspired by https://github.com/c3se/containers/tree/master/rpm-builds


### prepare build environment

#### build common apptainer image

(`sudo` needed here, expect size of ~ 300 MB)

```
sudo apptainer build ./base-rpmbuild-rocky86.sif ./base-rpmbuild-rocky86.def
```
#### build apptainer build image for pmix

( no need of `sudo`, fakeroot works well, expect ~ 315 MB image)

```
apptainer build --fakeroot ./build-pmix-rocky86.sif ./build-pmix-rocky86.def
```

### Build of pmix RPMs

#### unpack pmix tarball

..to have unpacked pmix here: `tarballs/pmix-3.2.4/`
..and copy original tarball into well-known directory:

```
cp tarballs/pmix-3.2.4.tar.bz2 $HOME/rpmbuild/SOURCES/
```

#### modify release number

..in `tarballs/pmix-3.2.4/contrib/pmix.spec`.

so eg. `vim tarballs/pmix-3.2.4/contrib/pmix.spec`..

and around line 196 we can insert YYYYMMDDHHmm:

```
195 Version: 3.2.4
196 Release: 202303311242%{?dist}
197 License: BSD
```

#### build in apptainer

```
apptainer exec ./build-pmix-rocky86.sif rpmbuild --define 'build_all_in_one_rpm 0' --define 'configure_options --disable-per-user-config-files' -ba ./tarballs/pmix-3.2.4/contrib/pmix.spec
```

should produce rpms in `$HOME/rpmbuild/RPMS/x86_64/`. The next container build will pick them there automatically.


### Build slurm RPMs

#### build apptainer image for slurm containing pmix rpms from step above..
(expect ~4.4 GB image size)

```
apptainer build --fakeroot ./build-slurm-rocky86.sif ./build-slurm-rocky86.def
```

#### modify release number

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

..and copy tarball into well-known directory: `cp tarballs/slurm-22.05.8.tar.bz2 $HOME/rpmbuild/SOURCES/slurm-22.05.8.tar.bz2`

#### build slurm rpms in apptainer

```
apptainer exec ./build-slurm-rocky86.sif rpmbuild --define '_with_nvml --with-nvml=/usr/local/cuda/targets/x86_64-linux/' --with pam --with slurmrestd --with hwloc --with lua --with mysql --with numa --with pmix -ba ./tarballs/slurm-22.05.8/slurm.spec &> slurm_build.log```

results should go into `$HOME/rpmbuild/RPMS/x86_64/`
