# build-slurm-rocky8
Build pmi-x and slurm rpms for Rocky8 with nvml support.

* changelog of upstream slurm project: https://github.com/SchedMD/slurm/blob/master/NEWS
* releases of openpmix upstream: https://github.com/openpmix/openpmix/releases

* Docker images used for build can be built by github actions https://github.com/jose-d/docker-images-rocky8

## How do build in your clone:

...in `.github/workflows/build.yml`:

* set/change `PMIX_VERSION` to version of openPMIX to be used as build dependency - PMI will be downloaded from its repository automatically
* set/change `SLURM_VERSION` to desired version of Slurm.
* set/change `NVML_VERSION` to NVML to link with slurm

..and then trigger the build.
