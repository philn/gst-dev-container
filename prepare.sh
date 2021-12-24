set -eux

# Fedora base image disable installing documentation files. See https://pagure.io/atomic-wg/issue/308
# We need them to cleanly build our doc.
sed -i "s/tsflags=nodocs//g" /etc/dnf/dnf.conf

dnf install -y git-core ninja-build dnf-plugins-core python3-pip

# Add rpm fusion repositories in order to access all of the gst plugins
sudo dnf install -y \
  "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
  "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

dnf upgrade -y

dnf copr enable -y philn/wpewebkit

# install rest of the extra deps
dnf install -y \
    aalib-devel \
    aom \
    bat \
    intel-mediasdk-devel \
    libaom \
    libaom-devel \
    libcaca-devel \
    libdav1d \
    libdav1d-devel \
    ccache \
    cmake \
    clang-devel \
    elfutils \
    elfutils-libs \
    elfutils-devel \
    gcc \
    gcc-c++ \
    gdb \
    git-lfs \
    graphviz \
    glslc \
    gtk3 \
    gtk3-devel \
    gtest \
    gtest-devel \
    graphene \
    graphene-devel \
    gsl \
    gsl-devel \
    gupnp \
    gupnp-devel \
    gupnp-igd \
    gupnp-igd-devel \
    gssdp \
    gssdp-devel \
    faac-devel \
    ffmpeg \
    ffmpeg-libs \
    ffmpeg-devel \
    flex \
    flite \
    flite-devel \
    mono-devel \
    procps-ng \
    patch \
    qt5-qtbase-devel \
    qt5-qtx11extras-devel \
    qt5-qtwayland-devel \
    redhat-rpm-config \
    json-glib \
    json-glib-devel \
    libnice \
    libnice-devel \
    libsodium-devel \
    libunwind \
    libunwind-devel \
    libva-devel \
    libyaml-devel \
    libxml2-devel \
    libxslt-devel \
    llvm-devel \
    log4c-devel \
    make \
    nasm \
    neon \
    neon-devel \
    nunit \
    npm \
    opencv \
    opencv-devel \
    openjpeg2 \
    openjpeg2-devel \
    SDL2 \
    SDL2-devel \
    sbc \
    sbc-devel \
    x264 \
    x264-libs \
    x264-devel \
    python3 \
    python3-devel \
    python3-libs \
    python3-wheel \
    python3-gobject \
    python3-cairo \
    python3-cairo-devel \
    valgrind \
    vulkan \
    vulkan-devel \
    mesa-dri-drivers \
    mesa-omx-drivers \
    mesa-libGL \
    mesa-libGL-devel \
    mesa-libGLU \
    mesa-libGLU-devel \
    mesa-libGLES \
    mesa-libGLES-devel \
    mesa-libOpenCL \
    mesa-libOpenCL-devel \
    mesa-libgbm \
    mesa-libgbm-devel \
    mesa-libd3d \
    mesa-libd3d-devel \
    mesa-libOSMesa \
    mesa-libOSMesa-devel \
    mesa-vulkan-drivers \
    wpewebkit \
    wpewebkit-devel \
    wpebackend-fdo-devel \
    xorg-x11-server-Xvfb

# Install common debug symbols
dnf debuginfo-install -y gtk3 \
    glib2 \
    glibc \
    gupnp \
    gupnp-igd \
    gssdp \
    freetype \
    openjpeg \
    gobject-introspection \
    python3 \
    python3-libs \
    python3-gobject \
    libappstream-glib-devel \
    libjpeg-turbo \
    glib-networking \
    libcurl \
    libsoup \
    nss \
    nss-softokn \
    nss-softokn-freebl \
    nss-sysinit \
    nss-util \
    openssl \
    openssl-libs \
    openssl-pkcs11 \
    brotli \
    bzip2-libs \
    gpm-libs \
    harfbuzz \
    harfbuzz-icu \
    json-c \
    json-glib \
    libbabeltrace \
    libffi \
    libsrtp \
    libunwind \
    mpg123-libs \
    neon \
    orc-compiler \
    orc \
    pixman \
    pulseaudio-libs \
    pulseaudio-libs-glib2 \
    wavpack \
    webrtc-audio-processing \
    ffmpeg \
    ffmpeg-libs \
    faad2-libs \
    libavdevice \
    libmpeg2 \
    faac \
    fdk-aac \
    x264 \
    x264-libs \
    x265 \
    x265-libs \
    xz \
    xz-libs \
    zip \
    zlib

# Install the dependencies of gstreamer
dnf builddep -y gstreamer1 \
    gstreamer1-plugins-base \
    gstreamer1-plugins-good \
    gstreamer1-plugins-good-extras \
    gstreamer1-plugins-ugly \
    gstreamer1-plugins-ugly-free \
    gstreamer1-plugins-bad-free \
    gstreamer1-plugins-bad-free-extras \
    gstreamer1-plugins-bad-freeworld \
    gstreamer1-libav \
    gstreamer1-rtsp-server  \
    gstreamer1-vaapi \
    python3-gstreamer1

dnf remove -y meson
pip3 install meson==0.59.2 hotdoc python-gitlab

# Remove gst-devel packages installed by builddep above
dnf remove -y "gstreamer1*devel"

# Remove svt-hevc until valgrind ignores it
dnf remove -y gstreamer1-svt-hevc 'svt-hevc*'

# FIXME: Why does installing directly with dnf doesn't actually install
# the documentation files?
dnf download glib2-doc gdk-pixbuf2-devel*x86_64* gtk3-devel-docs
rpm -i --reinstall *.rpm
rm -f *.rpm

# Install Rust
RUSTUP_VERSION=1.24.3
RUST_VERSION=1.55.0
RUST_ARCH="x86_64-unknown-linux-gnu"

dnf install -y wget
RUSTUP_URL=https://static.rust-lang.org/rustup/archive/$RUSTUP_VERSION/$RUST_ARCH/rustup-init
wget $RUSTUP_URL
dnf remove -y wget

chmod +x rustup-init;
./rustup-init -y --no-modify-path --profile minimal --default-toolchain $RUST_VERSION;
rm rustup-init;
chmod -R a+w $RUSTUP_HOME $CARGO_HOME

rustup --version
cargo --version
rustc --version

dnf install -y toolbox-experience
