FROM registry.fedoraproject.org/fedora:37

ENV NAME=gst-dev VERSION=37

ENV SHELL /bin/bash
ENV LANG C.UTF-8
LABEL com.github.containers.toolbox="true" \
      com.github.debarshiray.toolbox="true" \
      com.redhat.component="$NAME" \
      name="$NAME" \
      version="$VERSION" \
      usage="This image is meant to be used with the toolbox command" \
      summary="Base image for creating Fedora toolbox containers"

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH

ENV DEBUGINFOD_URLS=https://debuginfod.fedoraproject.org/

COPY prepare.sh cleanup.sh /root/

RUN /usr/bin/sh /root/prepare.sh && \
    /usr/bin/sh /root/cleanup.sh
