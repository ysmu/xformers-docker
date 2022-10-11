FROM nvidia/cuda:11.6.1-devel-ubuntu20.04

# 6.1 for 1000 series
ARG TORCH_CUDA_ARCH_LIST=6.1
ARG PYTHON_VERSION=3.10

RUN apt-get update \
  && apt-get install -y git g++ wget \
  && rm -rf /var/lib/apt/lists/*

RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
  && bash Miniconda3-latest-Linux-x86_64.sh -b \
  && rm -f Miniconda3-latest-Linux-x86_64.sh

ENV PATH=/root/miniconda3/bin:$PATH
RUN conda create -n xformers python=$PYTHON_VERSION
SHELL ["conda", "run", "--no-capture-output", "-n=xformers", "/bin/bash", "-c"]

WORKDIR /tmp/xformers
RUN git clone https://github.com/facebookresearch/xformers.git /tmp/xformers && git submodule update --init --recursive

# We have to install requirements.txt first because setup.py imports torch
RUN pip install -r requirements.txt --extra-index-url https://download.pytorch.org/whl/cu116
RUN FORCE_CUDA=1 TORCH_CUDA_ARCH_LIST=$TORCH_CUDA_ARCH_LIST pip wheel . --no-deps
RUN mkdir /out && cp /tmp/xformers/xformers-* /out/

