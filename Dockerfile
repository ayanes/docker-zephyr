FROM ubuntu:16.04

MAINTAINER Erik Stromdahl <erik.stromdahl@gmail.com>

RUN apt-get -y update
RUN apt-get -y upgrade

# Install prerequisites for Zephyr SDK
RUN apt-get -y install git make gcc g++ python3-ply ncurses-dev \
    python3-yaml python2.7 dfu-util

# Install prerequisites for OpenOCD
RUN apt-get -y install libtool automake pkg-config libusb-1.0-0-dev libhidapi-dev

# Install other useful tools
RUN apt-get -y install usbutils net-tools tmux telnet vim wget

# Simple root password in case we want to customize the container
RUN echo "root:root" | chpasswd

# OpenOCD version. The name must match a git tag in the OpenOCD repository
ARG OPENOCD_VERSION="v0.10.0"

# Build and install OpenOCD
RUN mkdir -p /build/openocd
ADD build_openocd.sh /build/openocd/build_openocd.sh
RUN OPENOCD_VERSION=$OPENOCD_VERSION /build/openocd/build_openocd.sh

# Zephyr SDK version
ARG ZEPHYR_SDK_VERSION="0.9"

# Install the Zephyr SDK
RUN mkdir -p /build/zephyr-sdk
WORKDIR /build/zephyr-sdk
RUN wget https://github.com/zephyrproject-rtos/meta-zephyr-sdk/releases/download/0.9/zephyr-sdk-$ZEPHYR_SDK_VERSION-setup.run && \
    chmod +x zephyr-sdk-$ZEPHYR_SDK_VERSION-setup.run && \
    ./zephyr-sdk-$ZEPHYR_SDK_VERSION-setup.run

# Add default user
RUN useradd -ms /bin/bash zephyr

USER zephyr

WORKDIR /home/zephyr

# Setup zephyr SDK
RUN echo export ZEPHYR_GCC_VARIANT=zephyr > .zephyrrc && \
    echo export ZEPHYR_SDK_INSTALL_DIR=/opt/zephyr-sdk >> .zephyrrc

ENTRYPOINT      ["/bin/bash"]
