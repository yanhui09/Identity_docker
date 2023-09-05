# Container image that runs your code
FROM mambaorg/micromamba
LABEL org.opencontainers.image.authors="Yan Hui <me@yanh.org>"
ADD . /tmp/repo
WORKDIR /tmp/repo
ENV LANG C.UTF-8
ENV SHELL /bin/bash
USER root 

ENV APT_PKGS bzip2 ca-certificates curl wget gnupg2 squashfs-tools build-essential git

RUN apt-get update \
    && apt-get install -y --no-install-recommends ${APT_PKGS} \
    && apt-get clean \
    && rm -rf /var/lib/apt /var/lib/dpkg /var/lib/cache /var/lib/log

RUN git clone https://github.com/BioinformaticsToolsmith/Identity.git

RUN micromamba env -q -y -c conda-forge -n identity cmake cxx-compiler \
    && eval "$(micromamba shell hook -s bash)" \
    && micromamba activate /opt/conda/envs/identity \
    && micromamba clean --all --yes

ENV PATH /opt/conda/envs/identity/bin:${PATH}

RUN cd Identity \
    && mkdir bin \
    && cd bin \
    && cmake .. \
    && make

ENV PATH /tmp/repo/Identity/bin:${PATH} 

WORKDIR /home
