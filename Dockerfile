# =========================
# Base image
# =========================
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# =========================
# 1️⃣ Install build dependencies (layer cached)
# =========================
RUN apt-get update && apt-get install -y \
    build-essential git wget curl python2 python-is-python2 python2-dev \
    flex bison gawk libtool automake autoconf \
    texinfo help2man libncurses5-dev libexpat1-dev unzip \
    sudo ca-certificates python3 python3-pip \
    screen minicom vim gperf libtool-bin \
    && rm -rf /var/lib/apt/lists/*

# Link python2 for old scripts
RUN ln -sf /usr/bin/python2 /usr/bin/python

# =========================
# 2️⃣ Create non-root build user
# =========================
RUN useradd -ms /bin/bash builder \
    && echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

WORKDIR /opt

# =========================
# 3️⃣ Clone repositories (layer cached)
# =========================
RUN git clone --recursive https://github.com/pfalcon/esp-open-sdk.git
RUN git clone https://github.com/SmingHub/Sming.git && \
    cd Sming && git checkout 4.2.0 -b v4.2.0
RUN git clone https://github.com/espressif/ESP8266_NONOS_SDK.git && \
    cd ESP8266_NONOS_SDK && git checkout v3.0.5 -b v3.0.5

# =========================
# 4️⃣ Apply patches (layer cached)
# =========================
COPY patches/bash-version.patch /tmp/bash-version.patch
COPY patches/companion-libs.patch /tmp/companion-libs.patch
COPY patches/sming.patch /tmp/sming.patch

RUN patch -p1 -d esp-open-sdk/crosstool-NG < /tmp/bash-version.patch && \
    patch -p1 -d esp-open-sdk/crosstool-NG < /tmp/companion-libs.patch && \
    patch -p1 -d Sming < /tmp/sming.patch

# Fix ownership
RUN sudo chown -R builder:builder esp-open-sdk Sming ESP8266_NONOS_SDK

# =========================
# 5️⃣ Build esp-open-sdk toolchain (long step, cached)
# =========================
USER builder
WORKDIR /opt/esp-open-sdk
RUN make STANDALONE=y

# =========================
# 6️⃣ Download ESP8266 NONOS SDK (cached)
# =========================
WORKDIR /opt

# =========================
# 7️⃣ Environment variables
# =========================
ENV HOME=/home/builder
ENV ESP_HOME=/opt/esp-open-sdk
ENV PATH=$ESP_HOME/xtensa-lx106-elf/bin:$PATH
ENV SMING_HOME=/opt/Sming/Sming
ENV ESP8266_NONOS_SDK=/opt/ESP8266_NONOS_SDK

WORKDIR /workspace

CMD ["/bin/bash"]
