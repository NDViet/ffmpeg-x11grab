FROM ubuntu:latest AS builder

RUN if [ "$(dpkg --print-architecture)" = "amd64" ]; then \
      echo "deb http://archive.ubuntu.com/ubuntu noble main universe\n" > /etc/apt/sources.list \
      && echo "deb http://archive.ubuntu.com/ubuntu noble-updates main universe\n" >> /etc/apt/sources.list \
      && echo "deb http://security.ubuntu.com/ubuntu noble-security main universe\n" >> /etc/apt/sources.list ; \
     fi \
  && apt-get -qqy update \
  && apt-get upgrade -yq \
  && apt-get -qqy --no-install-recommends install \
    autoconf \
    automake \
    cmake \
    libfreetype6 \
    gcc \
    build-essential \
    libtool \
    make \
    nasm \
    pkg-config \
    zlib1g-dev \
    numactl \
    libnuma-dev \
    libx11-6 \
    libxcb1 \
    libxcb1-dev \
    yasm \
    wget \
    unzip \
  && mkdir -p /usr/local/src

# libx264
RUN cd /usr/local/src \
    && wget --no-check-certificate https://code.videolan.org/videolan/x264/-/archive/master/x264-master.zip \
    && unzip x264-master.zip \
    && rm x264-master.zip \
    && cd x264-master \
    && ./configure --prefix="/usr/local" --enable-static \
    && make \
    && make install \
    && cd .. \
    && rm -rf x264-master

# ffmpeg
RUN cd /usr/local/src \
    && wget --no-check-certificate https://github.com/FFmpeg/FFmpeg/archive/refs/heads/release/7.1.zip \
    && unzip 7.1.zip \
    && rm 7.1.zip \
    && cd FFmpeg-release-7.1 \
    && PKG_CONFIG_PATH="/usr/local/lib/pkgconfig" ./configure \
    --prefix="/usr/local" \
    --extra-cflags="-I/usr/local/include" \
    --extra-ldflags="-L/usr/local/lib" \
    --pkg-config-flags="--static" \
    --enable-gpl \
    --enable-nonfree \
    --enable-libx264 \
    --enable-libxcb \
    && make \
    && make install \
    && cd .. \
    && rm -rf FFmpeg-release-7.1

# Final stage
FROM ubuntu:latest

COPY --from=builder /usr/local /usr/local

RUN apt-get -qqy update \
  && apt-get -qqy --no-install-recommends install \
    libx11-6 \
    libxcb1 \
    libxcb-shm0 \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN echo "**** quick test ffmpeg ****" \
    && ldd /usr/local/bin/ffmpeg \
    && /usr/local/bin/ffmpeg -version
