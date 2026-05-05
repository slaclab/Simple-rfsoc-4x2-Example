FROM ubuntu:22.04

# Install system tools for Yocto (previously petalinux)
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
    apt-get install -y --no-install-recommends tzdata && \
    apt-get install -y \
    autoconf \
    bc \
    bison \
    build-essential \
    ca-certificates \
    chrpath \
    cpio \
    curl \
    dbus \
    dbus-x11 \
    debianutils \
    diffstat \
    dnsutils  \
    expect \
    flex \
    fonts-droid-fallback \
    fonts-ubuntu-console \
    gawk \
    gcc-multilib \
    git \
    git-lfs \
    gnupg \
    gtk2-engines \
    gzip \
    iproute2 \
    iputils-ping \
    kmod \
    less \
    lib32z1-dev \
    libbz2-dev \
    libcanberra-gtk-module \
    libegl1-mesa \
    libffi-dev \
    libgdbm-dev \
    libglib2.0-dev \
    libgtk2.0-0 \
    libidn12 \
    libidn-dev \
    libidn2-dev \
    libjpeg62-dev \
    libpython3-dev \
    libncurses5-dev \
    libnss3-dev \
    libreadline-dev \
    libsdl1.2-dev \
    libselinux1 \
    libsqlite3-dev \
    libssl-dev \
    libswt-gtk-4-jni \
    libtinfo5 \
    libtinfo-dev \
    libtool \
    libtool-bin \
    locales \
    lsb-release \
    lxappearance \
    nano \
    net-tools \
    pax \
    pkg-config \
    pylint \
    python-is-python3 \
    python3 \
    python3-pexpect \
    python3-pip \
    python3-git \
    python3-jinja2 \
    rsync \
    screen \
    socat \
    sudo \
    texinfo \
    tftpd \
    tofrodos \
    u-boot-tools \
    ubuntu-gnome-default-settings \
    unzip \
    update-inetd \
    wget \
    xorg \
    xterm \
    xvfb \
    xxd \
    zlib1g-dev \
    liblz4-tool \
    zstd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN dpkg --add-architecture i386 && apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y -q \
    zlib1g:i386 libc6-dev:i386 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8

# make /bin/sh symlink to bash instead of dash:
RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

ENV LANG=en_US.UTF-8
ENV SHELL=/bin/bash

ARG uid
ARG gid
ARG user
RUN groupadd -g ${gid} -o ${user}
RUN useradd -m -N --gid ${gid} --shell /bin/bash --uid ${uid} ${user}

USER ${user}
WORKDIR /home/${user}
