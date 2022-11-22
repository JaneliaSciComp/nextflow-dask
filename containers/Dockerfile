FROM oraclelinux:8

ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=all

RUN dnf install -y \
        tar wget \
        hostname \
        procps-ng \
        net-tools \
        which

# Install miniconda
ENV DOWNLOAD_MAMBA_URL=https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh

RUN wget ${DOWNLOAD_MAMBA_URL} -O mamba-install.sh && \
    bash mamba-install.sh -b -p /opt/mambaforge

ENV PATH=/opt/mambaforge/bin:${PATH}

COPY conda-requirements.yml /tmp/

RUN mamba update --prefix /opt/mambaforge anaconda && \
    mamba env update -n base -f /tmp/conda-requirements.yml

RUN rm -rf /opt/mambaforge/pkgs