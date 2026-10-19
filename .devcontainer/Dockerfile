# syntax=docker/dockerfile:1@sha256:4edf897a3ffa55b89f906fc8cc78afdb3f1834cc9c7083565e611a8a7d5fe99e

ARG TARGETARCH

FROM scratch AS node-amd64

ADD --checksum=sha256:28ea0a438de9a13bd7891fd758eee6c7819ee8af5442dfd8d45bd65e56d4228c \
    https://nodejs.org/dist/v24.22.0/node-v24.22.0-linux-x64.tar.gz \
    /tmp/node.tgz

FROM scratch AS node-arm64

ADD --checksum=sha256:b7e7991d5407815adfa74a2a9cd4db683552c8ce32ff4a295c22e972849c3f5d \
    https://nodejs.org/dist/v24.22.0/node-v24.22.0-linux-arm64.tar.gz \
    /tmp/node.tgz

FROM node-${TARGETARCH} AS node

FROM scratch AS cmake-amd64

ADD --checksum=sha256:e5bb807f7728cb60cd8b27ebc97a2edb469b68655f21e844a600c3575b76f5bb \
    https://github.com/Kitware/CMake/releases/download/v4.4.4/cmake-4.4.4-linux-x86_64.tar.gz \
    /tmp/cmake.tgz

FROM scratch AS cmake-arm64

ADD --checksum=sha256:a1b6cc63636a0e55c63257cf3315a8a5f129e42fade25db1afea4ff8ab06f25e \
    https://github.com/Kitware/CMake/releases/download/v4.4.4/cmake-4.4.4-linux-aarch64.tar.gz \
    /tmp/cmake.tgz

FROM cmake-${TARGETARCH} AS cmake

FROM docker.io/library/ubuntu:26.04@sha256:c098726dd9b9733f3e885f8de0ef375206a311b0a317eadc40d347b1115fb944

COPY --from=node /tmp/node.tgz /tmp/node.tgz
COPY --from=cmake /tmp/cmake.tgz /tmp/cmake.tgz

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade --yes --no-install-recommends \
    && DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends ca-certificates clang-format curl gcc-16 gcovr gdb git libc6-dev libcurl4-openssl-dev libjson-c-dev libsqlite3-dev make ninja-build openssh-client python3 sqlite3 strace sudo valgrind \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-16 160 \
    && update-alternatives --install /usr/bin/cc cc /usr/bin/gcc-16 160 \
    && update-alternatives --install /usr/bin/gcov gcov /usr/bin/gcov-16 160 \
    && tar --extract --gzip --file /tmp/cmake.tgz --directory /usr/local --strip-components=1 \
    && tar --extract --gzip --file /tmp/node.tgz --directory /usr/local --strip-components=1 --no-same-owner --exclude='*/README.md' --exclude='*/CHANGELOG.md' --exclude='*/LICENSE' \
    && ln --symbolic /usr/local/bin/node /usr/local/bin/nodejs \
    && rm --force -- /tmp/cmake.tgz /tmp/node.tgz \
    && usermod --shell /bin/bash ubuntu \
    && install --directory --owner ubuntu --group ubuntu \
        /home/ubuntu/.local \
        /home/ubuntu/.local/bin \
        /home/ubuntu/.local/lib \
        /home/ubuntu/.local/lib/node_modules \
    && printf '%s\n' 'ubuntu ALL=(root) NOPASSWD:ALL' > /etc/sudoers.d/ubuntu \
    && chmod 0440 /etc/sudoers.d/ubuntu \
    && rm -rf /var/lib/apt/lists/*

ENV NPM_CONFIG_PREFIX=/home/ubuntu/.local
ENV PATH=/home/ubuntu/.local/bin:${PATH}

USER ubuntu
