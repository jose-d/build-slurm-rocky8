# build-slurm-rocky8
Build slurm rpms at Rocky8

credits:
strongly inspired by https://github.com/c3se/containers/tree/master/rpm-builds


### prepare build environment

#### build common apptainer image
```
apptainer build ./base-rpmbuild-rocky86.sif ./base-rpmbuild-rocky86.def
```


### build pmix

#### build apptainer build image for pmix

```
apptainer build ./build-pmix-rocky86.sif ./build-pmix-rocky86.def
```

#### unpack pmix tarball

..to have unpacked pmix here: `tarballs/pmix-3.2.4/`

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

should produce rpms in `$HOME/rpmbuild/RPMS/x86_64/`.

#### upload rpms into repo

(fixme)

### build slurm

#### build apptainer image for slurm containing pmix rpms from step above..

```
apptainer build ./build-slurm-rocky86.sif ./build-slurm-rocky86.def
```

#### modify release number

in `tarballs/slurm-22.05.8/slurm.spec`, so eg.: `vim tarballs/slurm-22.05.8/slurm.spec` and around line `3`:

```
  2 Version:        22.05.8
  3 %define rel     202303311312
  4 Release:        %{rel}%{?dist}
```

and also replace the following if block with 

```
%global slurm_source_dir %{name}-%{version}
```

as we build from the upstream tarball..

#### build slurm rpms in apptainer

```
apptainer exec ./build-slurm-rocky86.sif rpmbuild --define '_with_nvml --with-nvml=/usr/local/cuda/targets/x86_64-linux/' --with pam --with slurmrestd --with hwloc --with lua --with mysql --with numa --with pmix -ba ./tarballs/slurm-22.05.8/slurm.spec &> slurm_build.log```

