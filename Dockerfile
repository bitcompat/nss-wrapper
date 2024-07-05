# syntax=docker/dockerfile:1.17
FROM docker.io/bitnami/minideb:bookworm as builder

ARG PACKAGE=nss_wrapper
ARG TARGET_DIR=common
# renovate: datasource=git-tags depName=git://git.samba.org/nss_wrapper.git extractVersion=^nss_wrapper-(?<version>.*)$
ARG VERSION=1.1.16
ARG REF=nss_wrapper-${VERSION}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN install_packages ca-certificates curl git build-essential g++ cmake tar gzip bzip2 pkg-config

RUN <<EOT bash
    mkdir -p /opt/src/${PACKAGE}
    mkdir -p /opt/bitnami/${TARGET_DIR}
    mkdir -p /opt/bitnami/${TARGET_DIR}/licenses

    cd /opt/src
    git clone -b ${REF} git://git.samba.org/nss_wrapper.git nss_wrapper_source
    cd nss_wrapper
    cmake -DCMAKE_INSTALL_PREFIX=/opt/bitnami/${TARGET_DIR} -DCMAKE_BUILD_TYPE=Release ../${PACKAGE}_source
    make -j\$(nproc)
    make install

    rm -rf /opt/bitnami/${TARGET_DIR}/share
    cp -f ../nss_wrapper_source/LICENSE /opt/bitnami/${TARGET_DIR}/licenses/${PACKAGE}-${VERSION}.txt
EOT

FROM docker.io/bitnami/minideb:bookworm as stage-0

COPY --link --from=builder /opt/bitnami /opt/bitnami
