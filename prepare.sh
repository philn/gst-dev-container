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
    SDL2 \
    SDL2-devel \
    aalib-devel \
    aom \
    bat \
    ccache \
    clang-devel \
    cmake \
    elfutils \
    elfutils-devel \
    elfutils-libs \
    faac-devel \
    ffmpeg \
    ffmpeg-devel \
    ffmpeg-libs \
    flex \
    flite \
    flite-devel \
    gcc \
    gcc-c++ \
    gdb \
    git-lfs \
    glslc \
    graphene \
    graphene-devel \
    gsl \
    gsl-devel \
    gssdp \
    gssdp-devel \
    gtest \
    gtest-devel \
    gtk-doc \
    gtk3 \
    gtk3-devel \
    gtk4-devel \
    gupnp \
    gupnp-devel \
    gupnp-igd \
    gupnp-igd-devel \
    intel-mediasdk-devel \
    json-glib \
    json-glib-devel \
    libaom \
    libaom-devel \
    libasan \
    libcaca-devel \
    libdav1d \
    libdav1d-devel \
    libnice \
    libnice-devel \
    libsodium-devel \
    libunwind \
    libunwind-devel \
    libva-devel \
    libxml2-devel \
    libxslt-devel \
    libyaml-devel \
    llvm-devel \
    log4c-devel \
    make \
    mesa-dri-drivers \
    mesa-libGL \
    mesa-libGL-devel \
    mesa-libGLES \
    mesa-libGLES-devel \
    mesa-libGLU \
    mesa-libGLU-devel \
    mesa-libOSMesa \
    mesa-libOSMesa-devel \
    mesa-libOpenCL \
    mesa-libOpenCL-devel \
    mesa-libd3d \
    mesa-libd3d-devel \
    mesa-libgbm \
    mesa-libgbm-devel \
    mesa-omx-drivers \
    mesa-vulkan-drivers \
    mono-devel \
    nasm \
    neon \
    neon-devel \
    npm \
    nunit \
    opencv \
    opencv-devel \
    openjpeg2 \
    openjpeg2-devel \
    patch \
    pipewire-devel \
    procps-ng \
    python3 \
    python3-cairo \
    python3-cairo-devel \
    python3-devel \
    python3-gobject \
    python3-libs \
    python3-wheel \
    qt5-qtbase-devel \
    qt5-qtwayland-devel \
    qt5-qtx11extras-devel \
    qt5-qtquickcontrols \
    qt5-qtquickcontrols2 \
    qt5-qtbase-private-devel \
    redhat-rpm-config \
    sbc \
    sbc-devel \
    valgrind \
    vulkan \
    vulkan-devel \
    wayland-protocols-devel \
    wpebackend-fdo-devel \
    wpewebkit \
    wpewebkit-devel \
    x264 \
    x264-devel \
    x264-libs \
    xmlstarlet \
    xorg-x11-server-Xvfb

# VAAPI mess:
dnf -y remove mesa-va-drivers
dnf -y install mesa-va-drivers-freeworld

# ffmpeg mess:
dnf -y install libavcodec-freeworld

# Extra tools
dnf install -y \
    apitrace \
    apitrace-gui \
    direnv \
    fish \
    graphviz \
    indent \
    perf \
    rr \
    strace \
    sysprof \
    tmux \
    wget

# Install the dependencies of gstreamer
dnf builddep -y --allowerasing --skip-broken gstreamer1 \
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
pip3 install meson

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
RUSTUP_VERSION=1.25.1
RUST_VERSION=1.65.0
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
