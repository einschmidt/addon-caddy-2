ARG BUILD_FROM
# hadolint ignore=DL3006
FROM $BUILD_FROM

RUN \
  set -eux \
  \
  && mkdir -p \
    /data/caddy \
  \
  && apk add --no-cache \
    nss-tools=3.78.1-r0

# https://github.com/caddyserver/caddy/releases
ENV CADDY_VERSION 2.5.2

# Install Caddy
ARG BUILD_ARCH=amd64
RUN \
  set -eux \
  \
  && BINARCH="${BUILD_ARCH}" \
  && if [ "${BUILD_ARCH}" = "armhf" ]; then BINARCH="armv6"; fi \
  && if [ "${BUILD_ARCH}" = "armv7" ]; then BINARCH="armv7"; fi \
  && if [ "${BUILD_ARCH}" = "aarch64" ]; then BINARCH="arm64"; fi \
  \
  && curl -J -L -o /tmp/caddy.tar.gz "https://github.com/caddyserver/caddy/releases/download/v${CADDY_VERSION}/caddy_${CADDY_VERSION}_linux_${BINARCH}.tar.gz" \
  && tar zxvf /tmp/caddy.tar.gz -C /usr/bin caddy \
  && chmod +x /usr/bin/caddy \
  && rm -rf /tmp/caddy \
  && caddy version

# Copy root filesystem
COPY rootfs /

# set up nsswitch.conf for Go's "netgo" implementation
# - https://github.com/docker-library/golang/blob/1eb096131592bcbc90aa3b97471811c798a93573/1.14/alpine3.12/Dockerfile#L9
RUN [ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf

ENV XDG_CONFIG_HOME=/data
ENV XDG_DATA_HOME=/ssl

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Einschmidt" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="Einschmidt" \
    org.opencontainers.image.authors="einschmidt" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://google.com" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
