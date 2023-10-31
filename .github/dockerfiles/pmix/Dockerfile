FROM josed/build_slurm_base:latest

RUN dnf -y update
RUN dnf install -y zlib-devel hwloc-devel libevent-devel python3-devel jansson-devel
RUN python3 -m pip install sphinx

CMD ["echo", "Pmix_build_image"]
