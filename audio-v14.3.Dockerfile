FROM hiroshiba/hiho-docker-base:base-v14.3

ARG TARGETARCH

# install for audio utils, librosa, segmentation-kit
RUN apt-get update && \
    apt-get install -y sox ffmpeg && \
    apt-get install -y open-jtalk open-jtalk-mecab-naist-jdic hts-voice-nitech-jp-atr503-m001 && \
    apt-get install -y swig libsndfile1-dev libasound2-dev && \
    apt-get install -y perl pulseaudio build-essential && \
    apt-get install -y icu-devtools && \
    apt-get clean

# github
WORKDIR /github

# julius
RUN id=4182bf024872cf4ff4388475359d74695dd5ee16 && \
    curl -kL https://github.com/julius-speech/julius/archive/$id.zip >/tmp/github.zip && \
    unzip /tmp/github.zip -d /github/ && \
    rm /tmp/github.zip && \
    mv /github/julius* /github/julius && \
    cd /github/julius && \
    case "${TARGETARCH}" in \
    amd64) TRIPLE="x86_64-unknown-linux-gnu" ;; \
    arm64) TRIPLE="aarch64-unknown-linux-gnu" ;; \
    *) echo "Unsupported arch: ${TARGETARCH}"; exit 1 ;; \
    esac && \
    ./configure --build="${TRIPLE}" --enable-words-int --enable-setup=standard && \
    make -j && \
    make install && \
    rm -r /github/julius

# dictation-kit
RUN curl -kL https://github.com/Hiroshiba/dictation-kit-nolfs/archive/refs/heads/master.zip >/tmp/github.zip && \
    unzip /tmp/github.zip -d /github/ && \
    rm /tmp/github.zip && \
    mv /github/dictation-kit-nolfs* /github/dictation-kit && \
    cd /github/dictation-kit && \
    bash merge-large-files.sh

# segmentation-kit
RUN id=4b23e4b40acbf301731022a54aadad5a197ab2aa && \
    curl -kL https://github.com/Hiroshiba/segmentation-kit/archive/$id.zip >/tmp/github.zip && \
    unzip /tmp/github.zip -d /github/ && \
    rm /tmp/github.zip && \
    mv /github/segmentation-kit* /github/segmentation-kit

# shiro
RUN id=67b26caf907eb9a37a593699e1e6d8c8972cea6f && \
    curl -kL https://github.com/Hiroshiba/SHIRO/archive/$id.zip >/tmp/github.zip && \
    unzip /tmp/github.zip -d /github/ && \
    rm /tmp/github.zip && \
    mv /github/SHIRO* /github/SHIRO && \
    cd /github/SHIRO && \
    bash build.bash

# MFA
RUN conda install -c conda-forge montreal-forced-aligner "joblib<1.4"

WORKDIR /root
