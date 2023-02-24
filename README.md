# build-slurm-rocky8
Build slurm rpms at Rocky8


## build pmix

### build apptainer build image for pmix

```
```

### unpack pmix tarball

..to have unpacked pmix here: `tarballs/pmix-3.2.4/`

### modify release number in `tarballs/pmix-3.2.4/contrib/pmix.spec`

release can be eg. YYYYmmDDHHMM etc. Default is `-1`.

### build in apptainer

```
apptainer exec ./build-pmix-rocky86.sif rpmbuild --define 'build_all_in_one_rpm 0' --define 'configure_options --disable-per-user-config-files' -ba ./tarballs/pmix-3.2.4/contrib/pmix.spec
```

### upload rpms into repo

```
...
```

## build slurm

### build apptainer image for slurm containing pmix rpms from step above..

```
apptainer build ./build-slurm-rocky86.sif ./build-slurm-rocky86.def
```



