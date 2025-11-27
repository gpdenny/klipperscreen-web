# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-selkies:ubuntunoble

# set version label
ARG BUILD_DATE
ARG VERSION
ARG KLIPPERSCREEN_VERSION
LABEL build_version="KlipperScreen version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="gpdenny"

# title and branding
ENV TITLE=KlipperScreen \
    SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
    NO_GAMEPAD=true \
    LSIO_FIRST_PARTY=false

RUN \
  echo "**** add icon ****" && \
  curl -o \
    /usr/share/selkies/www/icon.png \
    https://upload.wikimedia.org/wikipedia/commons/a/a3/Klipper-logo_png.png && \
  echo "**** install packages ****" && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive \
  apt-get install --no-install-recommends -y \
    build-essential \
    gettext-base \
    git \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv \
    python3-gi \
    python3-gi-cairo \
    gir1.2-gtk-3.0 \
    gir1.2-pango-1.0 \
    libgirepository1.0-dev \
    libcairo2-dev \
    libopenjp2-7 \
    libxkbcommon-x11-0 \
    xdotool \
    libatlas-base-dev \
    fonts-freefont-ttf \
    librsvg2-common \
    libmpv2 \
    gir1.2-notify-0.7 \
    network-manager && \
  echo "**** install klipperscreen ****" && \
  if [ -z ${KLIPPERSCREEN_VERSION+x} ]; then \
    KLIPPERSCREEN_VERSION=$(curl -s "https://api.github.com/repos/KlipperScreen/KlipperScreen/tags" \
    | grep -m1 '"name":' | sed 's/.*"name": *"\([^"]*\)".*/\1/'); \
  fi && \
  echo "Installing KlipperScreen version: ${KLIPPERSCREEN_VERSION}" && \
  mkdir -p /opt/klipperscreen && \
  curl -L \
    "https://github.com/KlipperScreen/KlipperScreen/archive/refs/tags/${KLIPPERSCREEN_VERSION}.tar.gz" \
    | tar xz --strip-components=1 -C /opt/klipperscreen && \
  echo "**** setup python venv and install dependencies ****" && \
  python3 -m venv /opt/klipperscreen/venv --system-site-packages && \
  /opt/klipperscreen/venv/bin/pip install --no-cache-dir --upgrade pip && \
  /opt/klipperscreen/venv/bin/pip install --no-cache-dir \
    jinja2 \
    netifaces \
    requests \
    websocket-client \
    pycairo \
    PyGObject \
    python-mpv \
    dbus-python && \
  printf "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
  echo "**** cleanup ****" && \
  apt-get autoclean && \
  rm -rf \
    /config/.cache \
    /config/.launchpadlib \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3001
VOLUME /config
