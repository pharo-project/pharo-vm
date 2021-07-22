FROM arm64v8/ubuntu as base
WORKDIR /opt/pharo
ENV TZ=Europe/Paris
RUN set -eu; \
  ln -snf /usr/share/zoneinfo/$TZ /etc/localtime; \
  echo $TZ > /etc/timezone; \
  apt-get update; \
  apt-get install -q --assume-yes --no-install-recommends \
    ca-certificates \
    libcurl3-gnutls \
    build-essential \
    gcc \
    g++ \
    binutils \
    cmake \
    git \
    wget \
    unzip \
    uuid-dev \
    libssl-dev \
    libtool \
    automake \
    ; \
  apt-get clean; \
  useradd --uid 7431 --gid 100 --home-dir /opt/pharo --no-create-home --no-user-group pharo; \
  chown 7431:100 /opt/pharo -R; \
  chown 644 /opt/pharo -R; \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*; \
  true

FROM base as final
WORKDIR /opt/pharo
USER pharo
