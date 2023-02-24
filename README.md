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

release can be eg. YYYYmmDDHHMM etc. Default is `-1`.

#### build in apptainer

```
apptainer exec ./build-pmix-rocky86.sif rpmbuild --define 'build_all_in_one_rpm 0' --define 'configure_options --disable-per-user-config-files' -ba ./tarballs/pmix-3.2.4/contrib/pmix.spec
```

#### upload rpms into repo

```
...
```

### build slurm

#### build apptainer image for slurm containing pmix rpms from step above..

```
apptainer build ./build-slurm-rocky86.sif ./build-slurm-rocky86.def
```

#### modify release number

in `tarballs/slurm-22.05.8/slurm.spec`

#### build slurm rpms in apptainer

```
apptainer exec ./build-slurm-rocky86.sif rpmbuild --define '_with_nvml --with-nvml=/usr/local/cuda/targets/x86_64-linux/' --with pam --with slurmrestd --with hwloc --with lua --with mysql --with numa --with pmix -ba ./tarballs/slurm-22.05.8/slurm.spec
```

