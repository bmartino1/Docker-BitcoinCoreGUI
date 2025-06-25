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
    unattended-upgrades xdg-utils apt-utils curl jq tar gnupg ca-certificates git xz-utils bash mc nano vim sudo

# Install mousepad and explicitly include its dependencies to open bitcoin.conf from within...
RUN apt-get update && apt-get install -y \
    mousepad \
    aspell \
    aspell-en \
    dictionaries-common \
    emacsen-common \
    enchant-2 \
    hunspell-en-us \
    libaspell15 \
    libenchant-2-2 \
    libgspell-1-2 \
    libgspell-1-common \
    libgtksourceview-4-0 \
    libgtksourceview-4-common \
    libhunspell-1.7-0 \
    libmousepad0 \
    libtext-iconv-perl && \
    # Set mousepad as default editor and visual editor
    echo "export EDITOR=mousepad" >> /etc/profile && \
    echo "export VISUAL=mousepad" >> /etc/profile

# Configure unattended-upgrades for automatic secuiryt updates
RUN echo "unattended-upgrades unattended-upgrades/enable_auto_updates boolean true" | debconf-set-selections && \
    dpkg-reconfigure --frontend=noninteractive unattended-upgrades
#https://wiki.debian.org/UnattendedUpgrades

# Copy entrypoint and build script to auto grab lattest bitcoin...
COPY startapp.sh /startapp.sh
RUN chmod +x /startapp.sh

#Fix Bitcoin Permission for Build script ship with bitcon for those who don't use volumes.
RUN mkdir -p /config
RUN chown nobody:users -R /config
RUN chmod 777 -R /config

COPY build.sh /build.sh
RUN chmod +x /build.sh
RUN /build.sh

# Add app user before calling the script
RUN useradd -m -s /bin/bash app
COPY sethomefolder.sh /sethomefolder.sh
RUN chmod +x /sethomefolder.sh
RUN /sethomefolder.sh

#Fix Bitcoin Permission for Build script ship with bitcon for those who don't use volumes.
RUN chown nobody:users -R /config
RUN chmod 777 -R /config

#app user runs without sudo and is unable to...
RUN mkdir -p /etc/sudoers.d/
RUN echo "app ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/nopasswd

RUN apt-get update && apt-get upgrade -y

# Final cleanup to reduce image size
RUN apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#Info
VOLUME /config
EXPOSE 5800

# Entrypoint is aut done via scirpt for this debain docker DO NOT SPECIFY 
#ENTRYPOINT ["/startapp.sh"]
