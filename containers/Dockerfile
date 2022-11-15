FROM oraclelinux:8

ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=all

RUN dnf install -y \
        tar wget \
        hostname \
        net-tools \
        which

# Install miniconda
ENV DOWNLOAD_MAMBA_URL=https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh

RUN wget ${DOWNLOAD_MAMBA_URL} -O mamba-install.sh && \
    bash mamba-install.sh -b -p /opt/mambaforge

ENV PATH=/opt/mambaforge/bin:${PATH}

RUN mamba install -y \
    jq \
    python-blosc \
    nomkl \
    cmake \
    cytoolz \
    dask \
    lz4 \
    numpy \
    pandas \
    cachey \
    streamz
