FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04

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
    luajit && \
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
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >>~/.bashrc && \
    echo "conda activate base" >>~/.bashrc

ENV PATH /opt/conda/bin:$PATH
RUN conda init --all && conda install -y python=3.12.9

# pypi
RUN pip install \
    numpy \
    numba \
    cython \
    scipy \
    pandas \
    matplotlib \
    ipython \
    jupyter \
    bash_kernel \
    mypy \
    ruff \
    pytest \
    yq \
    gpustat \
    gdown \
    tensorboard \
    uv

# jupyter
RUN python -m bash_kernel.install

# ssh
RUN apt-get update && apt-get install -y openssh-server openssh-client wget && \
    apt-get clean && mkdir /var/run/sshd

RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh && \
    echo "wget --quiet \$GITHUB_KEYS -O /root/.ssh/authorized_keys" >/run.sh && \
    echo "chmod 600 /root/.ssh/authorized_keys" >>/run.sh && \
    echo "/usr/sbin/sshd -D" >>/run.sh

EXPOSE 22
CMD ["/bin/bash", "/run.sh"]
