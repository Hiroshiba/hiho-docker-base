FROM nvidia/cuda:12.8.1-cudnn-runtime-ubuntu24.04

ARG TARGETARCH

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update --fix-missing && \
    apt-get install -y --no-install-recommends \
    locales \
    wget \
    bzip2 \
    ca-certificates \
    curl \
    git \
    gcc \
    g++ \
    cmake \
    sudo \
    htop \
    jq \
    vim \
    tree \
    dstat \
    parallel \
    moreutils \
    rsync \
    git-lfs \
    zip \
    unzip \
    tmux \
    p7zip-full \
    bc \
    lua5.3 \
    luajit \
    nodejs \
    npm && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# environment
RUN locale-gen ja_JP.UTF-8
ENV LANG=ja_JP.UTF-8 \
    LANGUAGE=ja_JP:ja \
    LC_ALL=ja_JP.UTF-8

# kubernetes
RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates curl gnupg && \
    mkdir -p -m 755 /etc/apt/keyrings && \
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg && \
    chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg && \
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list && \
    chmod 644 /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && \
    apt-get install -y kubectl

# miniconda
RUN case "${TARGETARCH}" in \
    "amd64") ARCH="x86_64" ;; \
    "arm64") ARCH="aarch64" ;; \
    *) echo "Unsupported arch: ${TARGETARCH}"; exit 1 ;; \
    esac && \
    wget -q https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-${ARCH}.sh -O ~/miniforge.sh && \
    /bin/bash ~/miniforge.sh -b -p /opt/conda && \
    rm ~/miniforge.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >>~/.bashrc && \
    echo "conda activate base" >>~/.bashrc

ENV PATH=/opt/conda/bin:$PATH
RUN conda init --all && conda install -y python=3.11.11

# pypi
RUN pip install \
    gpustat \
    yq \
    tensorboard \
    gdown \
    ipython \
    jupyter \
    bash_kernel \
    mypy \
    ruff \
    pytest

# uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
RUN mkdir -p /opt/uv && \
    cd /opt/uv && \
    echo 3.11.11 >> .python-version && \
    uv init --bare . && \
    uv add \
    numpy \
    numba \
    cython \
    scipy \
    pandas \
    matplotlib \
    mypy \
    ruff \
    pytest

# npm
RUN npm install -g @anthropic-ai/claude-code @openai/codex

# ssh
RUN apt-get update && apt-get install -y openssh-server openssh-client && \
    apt-get clean && mkdir /var/run/sshd

RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh && \
    echo "wget --quiet \$GITHUB_KEYS -O /root/.ssh/authorized_keys" >/run.sh && \
    echo "chmod 600 /root/.ssh/authorized_keys" >>/run.sh && \
    echo "/usr/sbin/sshd -D" >>/run.sh

EXPOSE 22
CMD ["/bin/bash", "/run.sh"]
