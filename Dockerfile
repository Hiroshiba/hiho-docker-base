FROM ubuntu:18.04

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH /opt/conda/bin:$PATH

RUN apt-get update --fix-missing && \
    apt-get install -y \
      wget \
      bzip2 \
      ca-certificates \
      curl \
      git \
      gcc \
      g++ \
      cmake \
      sudo \
      jq \
      vim \
      tree \
      dstat \
      parallel \
      git-lfs \
      && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# miniconda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-4.7.12-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

RUN conda install -y python=3.7.5

# python utility
RUN pip install pipx && \
    pipx install \
      yq \
      gpustat \
      mypy

CMD ["bash"]
