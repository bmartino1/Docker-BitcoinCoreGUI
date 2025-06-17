FROM jlesage/baseimage-gui:debian-12-v4.7.1

#English Locales
RUN \
    add-pkg locales && \
    sed-patch 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG=en_US.UTF-8

# GUI env
ARG APP_ICON="https://bitcoin.org/img/icons/opengraph.png"
RUN set-cont-env APP_NAME "Bitcoin-QT"
RUN set-cont-env DISPLAY_WIDTH "1280"
RUN set-cont-env DISPLAY_HEIGHT "800"
RUN set-cont-env APP_VERSION "Latest"

# Install necessary libraries for bitcoin-qt and bitcoind for script
RUN apt-get -yq update && apt-get -yq install \
    libfontconfig1 \
    libxcb1 \
    libxrender1 \
    libxcb-icccm4 \
    libxkbcommon-x11-0 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    build-essential \
    autoconf \
    libssl-dev \
    libboost-dev \
    libboost-chrono-dev \
    libboost-filesystem-dev \
    libboost-program-options-dev \
    libboost-system-dev \
    libboost-test-dev \
    libboost-thread-dev \
    qtbase5-dev \
    libprotobuf-dev \
    protobuf-compiler \
    libqrencode-dev \
    libdb5.3++-dev \
    libdb5.3-dev \
    unattended-upgrades apt-utils curl jq tar gnupg ca-certificates git xz-utils bash mc nano

# Configure unattended-upgrades for automatic secuiryt updates
RUN echo "unattended-upgrades unattended-upgrades/enable_auto_updates boolean true" | debconf-set-selections && \
    dpkg-reconfigure --frontend=noninteractive unattended-upgrades

# Copy entrypoint and build script to auto grab lattest bitcoin...
COPY startapp.sh /startapp.sh
RUN chmod +x /startapp.sh

#Fix Bitcoin Permission for Build script ship with bitcon for those who don't use volumes.
RUN mkdir /config
RUN chown nobody:users -R /config
RUN chmod 777 -R /config

COPY build.sh /build.sh
RUN chmod +x /build.sh
RUN /build.sh

#Info
VOLUME /config
EXPOSE 5800

# Entrypoint is aut done via scirpt for this debain docker DO NOT SPECIFY 
#ENTRYPOINT ["/startapp.sh"]
