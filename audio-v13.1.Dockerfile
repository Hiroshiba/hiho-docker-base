FROM hiroshiba/hiho-docker-base:base-v13.1

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
    rm -r /github/julius && \
    rm /tmp/github.zip

# dictation-kit
RUN id=1ceb4dec245ef482918ca33c55c71d383dce145e && \
    git clone https://github.com/julius-speech/dictation-kit.git && \
    cd dictation-kit && \
    git reset --hard $id && \
    git lfs pull && \
    rm -rf .git

# segmentation-kit
RUN id=4b23e4b40acbf301731022a54aadad5a197ab2aa && \
    curl -kL https://github.com/Hiroshiba/segmentation-kit/archive/$id.zip >/tmp/github.zip && \
    unzip /tmp/github.zip -d /github/ && \
    mv /github/segmentation-kit* /github/segmentation-kit && \
    rm /tmp/github.zip

# shiro
RUN id=67b26caf907eb9a37a593699e1e6d8c8972cea6f && \
    curl -kL https://github.com/Hiroshiba/SHIRO/archive/$id.zip >/tmp/github.zip && \
    unzip /tmp/github.zip -d /github/ && \
    mv /github/SHIRO* /github/SHIRO && \
    cd /github/SHIRO && \
    bash build.bash && \
    rm /tmp/github.zip

# MFA
RUN conda install -c conda-forge montreal-forced-aligner "joblib<1.4"

# uv
RUN cd /opt/uv && \
    uv add \
    librosa \
    ffmpeg-python \
    pyopenjtalk \
    pyworld \
    git+https://github.com/Hiroshiba/openjtalk-label-getter@5e55da14bdda6386dae63ddb67853c65a550df9a \
    git+https://github.com/Hiroshiba/julius4seg@e14beae2940fd5a6ac5a9d2afc249eac6fac4a50

WORKDIR /root
