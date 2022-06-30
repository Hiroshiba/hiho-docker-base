FROM hiroshiba/hiho-docker-base:v9.1

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
    curl -kL https://github.com/julius-speech/julius/archive/$id.zip > /tmp/github.zip && \
    unzip /tmp/github.zip -d /github/ && \
    mv /github/julius* /github/julius && \
    cd /github/julius && \
    CC=nvcc CFLAGS=-O3 ./configure --enable-words-int --enable-setup=standard && \
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
    curl -kL https://github.com/Hiroshiba/segmentation-kit/archive/$id.zip > /tmp/github.zip && \
    unzip /tmp/github.zip -d /github/ && \
    mv /github/segmentation-kit* /github/segmentation-kit && \
    rm /tmp/github.zip

# pypi
RUN pip install \
    librosa==0.8.1 \
    ffmpeg-python \
    git+https://github.com/Hiroshiba/acoustic_feature_extractor@270362a40aaa8aff3e66da8f45447aeedccae163 \
    git+https://github.com/Hiroshiba/openjtalk-label-getter@60519cfa75395fcf1564cc48a24956902d769c8b \
    git+https://github.com/Hiroshiba/julius4seg@e14beae2940fd5a6ac5a9d2afc249eac6fac4a50

WORKDIR /root
