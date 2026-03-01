FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Base tools
RUN apt-get update && apt-get install -y \
    build-essential \
    git wget curl \
    python2 python-is-python2 python2-dev \
    flex bison gawk \
    libtool automake autoconf \
    texinfo help2man \
    libncurses5-dev \
    libexpat1-dev \
    unzip \
    sudo \
    ca-certificates \
    python3 \
    python3-pip \
    screen \
    minicom \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Needed by old SDK scripts
RUN ln -sf /usr/bin/python2 /usr/bin/python

RUN apt-get update && \
apt-get install -y software-properties-common && \
add-apt-repository universe && \
apt-get update

# Create build user (required by crosstool-NG)
RUN useradd -ms /bin/bash builder

RUN apt-get install -y gperf libtool libtool-bin

WORKDIR /opt

# esp-open-sdk
RUN git clone --recursive https://github.com/pfalcon/esp-open-sdk.git
RUN git clone https://github.com/SmingHub/Sming.git && \
    cd Sming && git checkout 4.2.0 -b v4.2.0
RUN git clone https://github.com/espressif/ESP8266_NONOS_SDK.git && \
    cd ESP8266_NONOS_SDK && git checkout v3.0.5 -b v3.0.5

WORKDIR /opt/Sming
COPY patches/sming.patch /tmp
RUN patch -p1 < /tmp/sming.patch

WORKDIR /opt/esp-open-sdk

COPY patches/bash-version.patch /tmp/bash-version.patch
RUN patch -p1 -d crosstool-NG < /tmp/bash-version.patch
COPY patches/companion-libs.patch /tmp
RUN patch -p1 -d crosstool-NG < /tmp/companion-libs.patch

RUN chown -R builder:builder /opt/esp-open-sdk
RUN chown -R builder:builder /opt/Sming
RUN chown -R builder:builder /opt/ESP8266_NONOS_SDK

USER builder

# Build toolchain (takes 30–60 min first time)
RUN make STANDALONE=y

# Environment
ENV HOME=/home/builder
ENV ESP_HOME=/opt/esp-open-sdk
ENV PATH=$ESP_HOME/xtensa-lx106-elf/bin:$PATH
ENV SMING_HOME=/opt/Sming/Sming
ENV ESP8266_NONOS_SDK=/opt/ESP8266_NONOS_SDK

WORKDIR /workspace

CMD ["/bin/bash"]
