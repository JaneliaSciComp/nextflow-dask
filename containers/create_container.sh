docker build \
       --platform linux/amd64 \
       -t registry.int.janelia.org/janeliascicomp/dask:2023.8.1 \
       -t janeliascicomp/dask:2023.8.1 \
       $*
