docker buildx build \
       --platform linux/amd64,linux/arm64 \
       -t janeliascicomp/dask:2023.8.1 \
       --push \
       $*
