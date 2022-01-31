FROM debian:bullseye

# install xpra
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y curl gnupg && \
    curl -fsSL http://winswitch.org/gpg.asc | apt-key add - && \
    echo "deb http://winswitch.org/ bullseye main" > /etc/apt/sources.list.d/winswitch.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y xpra xvfb locales xterm && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    sed -i -e 's/# uk_UA.UTF-8 UTF-8/uk_UA.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen

ADD infinityTerm.sh /usr/local/bin/infinityTerm

# non-root user
RUN adduser --disabled-password --gecos "User" --uid 1000 user

ENV LANGUAGE uk_UA.UTF-8
ENV LANG uk_UA.UTF-8
ENV LC_ALL uk_UA.UTF-8

# install all X apps here
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y  libreoffice-calc libreoffice-writer && \
    apt-get clean && \ 
    rm -rf /var/lib/apt/lists/*

# additional fonts
RUN echo "deb http://httpredir.debian.org/debian bullseye main contrib non-free" > /etc/apt/sources.list \
    && echo "deb http://httpredir.debian.org/debian bullseye-updates main contrib non-free" >> /etc/apt/sources.list \
    && echo "deb http://security.debian.org/debian-security bullseye-security main contrib non-free" >> /etc/apt/sources.list \
    && echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections \
    && apt-get update \
    && apt-get install -y \
        ttf-mscorefonts-installer \
    && apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

USER user

ENV DISPLAY=:100

VOLUME /data

WORKDIR /data

EXPOSE 10000

CMD xpra start --bind-tcp=0.0.0.0:10000 --html=on --start-child=infinityTerm --exit-with-children --daemon=no --xvfb="/usr/bin/Xvfb +extension  Composite -screen 0 1920x1080x24+32 -nolisten tcp -noreset" --pulseaudio=no --notifications=no --bell=no --encoding=webp --file-transfer=off --video-encoders=none --webcam=no
