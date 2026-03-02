# =========================
# Base image
# =========================
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# =========================
# Install build dependencies (layer cached)
# =========================
RUN apt-get update && apt-get install -y \
    build-essential git wget curl \
    python3 python3-dev python3-pip python3-venv \
    flex bison gawk libtool automake autoconf \
    texinfo help2man libncurses5-dev libexpat1-dev unzip \
    sudo ca-certificates \
    screen minicom vim gperf libtool-bin \
    && rm -rf /var/lib/apt/lists/*


WORKDIR /opt

# ====================
#  Clone repositories
# ====================
RUN git clone https://github.com/SmingHub/Sming.git


# ===========================
# Fix ownership
# ===========================
WORKDIR /opt
RUN sudo chown -R ubuntu:ubuntu .

RUN ln -sf /usr/bin/python3 /usr/bin/python

RUN echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER ubuntu

WORKDIR /opt/Sming

RUN Tools/install.sh esp8266


RUN git config --global user.email "ubuntu@example.com" && \
    git config --global user.name "Builder"

# =========================
# Environment variables
# =========================
ENV HOME=/workspace
ENV ESP_HOME=/opt/esp-quick-toolchain
ENV PATH=$ESP_HOME/xtensa-lx106-elf/bin:$PATH
ENV SMING_HOME=/opt/Sming/Sming

WORKDIR /workspace

CMD ["/bin/bash"]
