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

WORKDIR /opt/esp-open-sdk

COPY bash-version.patch /tmp/bash-version.patch
RUN patch -p1 -d crosstool-NG < /tmp/bash-version.patch
COPY companion-libs.patch /tmp
RUN patch -p1 -d crosstool-NG < /tmp/companion-libs.patch

RUN chown -R builder:builder /opt/esp-open-sdk

USER builder

# Build toolchain (takes 30–60 min first time)
# RUN make STANDALONE=y

# Environment
ENV HOME=/home/builder
ENV ESP_HOME=/opt/esp-open-sdk
ENV PATH=$ESP_HOME/xtensa-lx106-elf/bin:$PATH

# WORKDIR /workspace

CMD ["/bin/bash"]
