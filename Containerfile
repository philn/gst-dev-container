FROM registry.fedoraproject.org/fedora-toolbox:42

ENV NAME=gst-dev VERSION=42

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH

ENV DEBUGINFOD_URLS=https://debuginfod.fedoraproject.org/

# Fedora base image disable installing documentation files. See https://pagure.io/atomic-wg/issue/308
# We need them to cleanly build our doc.
RUN sed -i "s/tsflags=nodocs//g" /etc/dnf/dnf.conf

RUN dnf install -y git-core ninja-build dnf-plugins-core python3-pip

# Add rpm fusion repositories in order to access all of the gst plugins
RUN dnf install -y \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

RUN dnf upgrade -y

RUN dnf copr enable -y philn/wpewebkit

COPY packages /
RUN dnf -y install $(cat packages | xargs)

# VAAPI mess:
RUN dnf -y remove mesa-va-drivers
RUN dnf -y install mesa-va-drivers-freeworld

# Install the dependencies of gstreamer
RUN dnf builddep -y --allowerasing gstreamer1 \
    gstreamer1-plugins-base \
    gstreamer1-plugins-good \
    gstreamer1-plugins-good-extras \
    gstreamer1-plugins-ugly \
    gstreamer1-plugins-ugly-free \
    gstreamer1-plugins-bad-free \
    gstreamer1-plugins-bad-free-extras \
    gstreamer1-plugins-bad-freeworld \
    gstreamer1-rtsp-server


RUN dnf remove -y meson
RUN pip3 install meson
RUN pip3 install gst-indent
RUN pip3 install pre-commit

# Remove gst-devel packages installed by builddep above
RUN dnf remove -y "gstreamer1*devel"

# Remove svt-hevc until valgrind ignores it
RUN dnf remove -y gstreamer1-svt-hevc 'svt-hevc*'

# FIXME: Why does installing directly with dnf doesn't actually install
# the documentation files?
RUN dnf download glib2-doc gdk-pixbuf2-devel*x86_64* gtk3-devel-docs
RUN rpm -i --reinstall *.rpm
RUN rm -f *.rpm

# Install Rust
ARG RUSTUP_VERSION=1.28.1
ARG RUST_VERSION=1.86.0
ENV RUST_ARCH="x86_64-unknown-linux-gnu"
ENV RUSTUP_URL=https://static.rust-lang.org/rustup/archive/$RUSTUP_VERSION/$RUST_ARCH/rustup-init
RUN wget $RUSTUP_URL

RUN chmod +x rustup-init
RUN ./rustup-init -y --no-modify-path --profile minimal --default-toolchain $RUST_VERSION
RUN rm rustup-init

RUN rustup --version
RUN cargo --version
RUN rustc --version

RUN dnf clean all
RUN rm -rf /var/cache/dnf /var/log/dnf*
