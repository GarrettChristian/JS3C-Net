FROM nvidia/cuda:10.1-cudnn8-devel-ubuntu18.04



RUN apt update && apt upgrade -y
RUN apt install -y python3 python3-dev python3-pip
RUN apt install -y git 

RUN pip3 install torch==1.3.1
RUN alias python=python3
RUN echo 'alias python=python3' >> ~/.bashrc
RUN python --version


RUN git clone https://github.com/yanx27/JS3C-Net.git
WORKDIR /JS3C-Net/lib
RUN git checkout d505d0b796cc48328d41b6ec0f5ca818eb42d4f8
RUN bash compile.sh

# Pytorch 1.3.1


# CUDA 10.1


