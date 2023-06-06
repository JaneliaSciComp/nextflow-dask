docker buildx build \
       --platform linux/amd64 \
       -t registry.int.janelia.org/janeliascicomp/dask:2023.3.2 \
       -t janeliascicomp/dask:2023.3.2 \
       $*
