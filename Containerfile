ARG TARGETARCH

FROM scratch AS node-amd64

ADD --checksum=sha256:5848553868b402d3fabb5b09270649977780a390f832155721025a08b5104455 https://nodejs.org/dist/v26.13.0/node-v26.13.0-linux-x64.tar.gz /tmp/node.tgz

FROM scratch AS node-arm64

ADD --checksum=sha256:439e9c438acdf6a6ffe47418da709153d66c4bed812e30a473faacb107dd2791 https://nodejs.org/dist/v26.13.0/node-v26.13.0-linux-arm64.tar.gz /tmp/node.tgz

FROM node-${TARGETARCH} AS node

FROM scratch AS cmake-amd64

ADD --checksum=sha256:81f0d5b0960fb6adc8197030ffc827fba937640d51e73e39e0e9e40d88c66f6f https://github.com/Kitware/CMake/releases/download/v4.5.0/cmake-4.5.0-linux-x86_64.tar.gz /tmp/cmake.tgz

FROM scratch AS cmake-arm64

ADD --checksum=sha256:0c8447e7bba9701467b5ac6155d157aa9e309e71af4981f78bd4b9176107f553 https://github.com/Kitware/CMake/releases/download/v4.5.0/cmake-4.5.0-linux-aarch64.tar.gz /tmp/cmake.tgz

FROM cmake-${TARGETARCH} AS cmake

FROM docker.io/library/ubuntu:26.04@sha256:19fcd1bf268f02b60aca3bd30bd8a6d9a11759a430e32921833e65f16d87348a AS workspace

ADD --chmod=0644 --checksum=sha256:8b2a587ffd672c4687e7581dad4b2f6c1bb2ad6b480cd9771ba2ff48e0b8c75d https://apt.llvm.org/llvm-snapshot.gpg.key /etc/apt/keyrings/llvm.asc

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade --yes --no-install-recommends \
    && DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends ca-certificates fd-find gcc gcovr gdb git libatomic1 libc6-dev make ninja-build openssh-client shellcheck strace sudo valgrind \
    && printf '%s\n' 'deb [signed-by=/etc/apt/keyrings/llvm.asc] https://apt.llvm.org/resolute/ llvm-toolchain-resolute-23 main' > /etc/apt/sources.list.d/llvm.list \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends clang-format-23 \
    && ln --symbolic /usr/bin/clang-format-23 /usr/local/bin/clang-format \
    && ln --symbolic /usr/bin/fdfind /usr/local/bin/fd \
    && printf '%s\n' 'ubuntu ALL=(root) NOPASSWD:ALL' > /etc/sudoers.d/ubuntu \
    && chmod 0440 /etc/sudoers.d/ubuntu \
    && rm -rf /var/lib/apt/lists/*

RUN --mount=type=bind,from=node,source=/tmp/node.tgz,target=/tmp/node.tgz \
    tar --extract --gzip --file /tmp/node.tgz --directory /usr/local --strip-components=1 --no-same-owner --exclude='*/README.md' --exclude='*/CHANGELOG.md' --exclude='*/LICENSE' \
    && ln --symbolic /usr/local/bin/node /usr/local/bin/nodejs

RUN npm install --global --prefix=/usr/local --ignore-scripts npm@12.2.1 \
    && rm -rf /root/.npm

RUN --mount=type=bind,from=cmake,source=/tmp/cmake.tgz,target=/tmp/cmake.tgz \
    tar --extract --gzip --file /tmp/cmake.tgz --directory /usr/local --strip-components=1 --no-same-owner

ENV LANG=C.UTF-8
ENV NPM_CONFIG_PREFIX=/home/ubuntu/.local
ENV PATH=/home/ubuntu/.local/bin:${PATH}

USER ubuntu

RUN mkdir -p "$HOME/.local/bin" "$HOME/.local/lib/node_modules"
