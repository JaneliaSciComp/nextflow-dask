FROM oraclelinux:9

ARG TARGETPLATFORM

ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=all

RUN dnf install -y \
        tar wget \
        hostname \
        procps-ng \
        net-tools \
        which

# Install miniconda
RUN wget https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-$(uname -m).sh \
    -O mamba-install.sh && \
    bash mamba-install.sh -b -p /opt/mambaforge

ENV PATH=/opt/mambaforge/bin:${PATH}

COPY conda-requirements.yml /tmp/

RUN mamba env update -n base -f /tmp/conda-requirements.yml

RUN rm -rf /opt/mambaforge/pkgs