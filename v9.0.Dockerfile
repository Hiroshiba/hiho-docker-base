FROM nvidia/cuda:11.6.2-cudnn8-devel-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update --fix-missing && \
    apt-get install -y \
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
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# environment
RUN locale-gen ja_JP.UTF-8
ENV LANG=ja_JP.UTF-8 \
    LANGUAGE=ja_JP:ja \
    LC_ALL=ja_JP.UTF-8

# kubernetes
RUN apt-get update && \
    apt-get install -y apt-transport-https gnupg && \
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && \
    apt-get install -y kubectl

# miniconda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-py39_4.12.0-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

ENV PATH /opt/conda/bin:$PATH
RUN conda install -y python=3.9.4

# conda
RUN conda install -y \
        numpy \
        numba

# pypi
RUN pip install \
        scipy \
        pandas \
        matplotlib \
        ipython \
        jupyter \
        bash_kernel \
        mypy \
        pytest \
        yq \
        gpustat

# jupyter
RUN python -m bash_kernel.install

# ssh
RUN apt-get update && apt-get install -y openssh-server openssh-client wget && \
    apt-get clean && mkdir /var/run/sshd

RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh && \
    echo "wget --quiet \$GITHUB_KEYS -O /root/.ssh/authorized_keys" > /run.sh && \
    echo "chmod 600 /root/.ssh/authorized_keys" >> /run.sh && \
    echo "/usr/sbin/sshd -D" >> /run.sh

EXPOSE 22
CMD ["/bin/bash", "/run.sh"]
