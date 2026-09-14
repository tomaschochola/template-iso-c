# syntax=docker/dockerfile:1@sha256:ecfaec9ed6d810b56388c508f4121597bfbba70d41a6dfeee4d8cad5f295fc32

ARG TARGETARCH

FROM scratch AS node-amd64

ADD --checksum=sha256:855d581f8a4eb1a8117e3426de25fe02770592febcfb31369aee1ffbfee9e8ec \
    https://nodejs.org/dist/v24.20.0/node-v24.20.0-linux-x64.tar.gz \
    /tmp/node.tgz

FROM scratch AS node-arm64

ADD --checksum=sha256:3515603e2487879a39bc75716f1a2affd027500c64ba50e845cf72cb33219013 \
    https://nodejs.org/dist/v24.20.0/node-v24.20.0-linux-arm64.tar.gz \
    /tmp/node.tgz

FROM node-${TARGETARCH} AS node

FROM scratch AS cmake-amd64

ADD --checksum=sha256:d6c83076c575bc00b823522ac974bda66d0af05d6ddc30e739c12385cf32c6cc \
    https://github.com/Kitware/CMake/releases/download/v4.4.3/cmake-4.4.3-linux-x86_64.tar.gz \
    /tmp/cmake.tgz

FROM scratch AS cmake-arm64

ADD --checksum=sha256:2efc974dbd63b4444c0e8494b92f2e80c2d7e635b4b80eac2916985ddd8f72a6 \
    https://github.com/Kitware/CMake/releases/download/v4.4.3/cmake-4.4.3-linux-aarch64.tar.gz \
    /tmp/cmake.tgz

FROM cmake-${TARGETARCH} AS cmake

FROM docker.io/library/gcc:trixie@sha256:b98be39c2378222af9dcab6a5b1707d74b47d7c413c8569d5429a4cbfefbe981

COPY --from=node /tmp/node.tgz /tmp/node.tgz
COPY --from=cmake /tmp/cmake.tgz /tmp/cmake.tgz

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade --yes --no-install-recommends \
    && DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends git make ninja-build openssh-client sudo valgrind \
    && tar --extract --gzip --file /tmp/cmake.tgz --directory /usr/local --strip-components=1 \
    && tar --extract --gzip --file /tmp/node.tgz --directory /usr/local --strip-components=1 --exclude='*/README.md' --exclude='*/CHANGELOG.md' --exclude='*/LICENSE' \
    && rm --force -- /tmp/cmake.tgz /tmp/node.tgz \
    && groupadd --gid 1000 devcontainer \
    && useradd --uid 1000 --gid devcontainer --shell /bin/bash --create-home devcontainer \
    && install --directory --owner devcontainer --group devcontainer \
        /home/devcontainer/.local \
        /home/devcontainer/.local/bin \
        /home/devcontainer/.local/lib \
        /home/devcontainer/.local/lib/node_modules \
    && printf '%s\n' 'devcontainer ALL=(root) NOPASSWD:ALL' > /etc/sudoers.d/devcontainer \
    && chmod 0440 /etc/sudoers.d/devcontainer \
    && rm -rf /var/lib/apt/lists/*

ENV NPM_CONFIG_PREFIX=/home/devcontainer/.local
ENV PATH=/home/devcontainer/.local/bin:${PATH}

USER devcontainer
