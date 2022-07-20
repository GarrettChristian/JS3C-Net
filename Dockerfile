FROM nvidia/cuda:10.1-cudnn8-devel-ubuntu18.04


RUN apt update && apt upgrade -y
RUN apt install -y python3 python3-dev python3-pip
RUN apt install -y git wget unzip

# get newer version of cmake
RUN wget https://apt.kitware.com/kitware-archive.sh
RUN chmod +x kitware-archive.sh && ./kitware-archive.sh

RUN pip3 install torch==1.6.0
RUN pip3 install cython==0.29.24
RUN pip3 install pyyaml==5.1.1
RUN pip3 install tqdm==4.64.0



RUN git clone https://github.com/GarrettChristian/JS3C-Net.git
WORKDIR /JS3C-Net/lib
RUN bash compile.sh
WORKDIR /

RUN ls /usr/local

# SpConv
# need to use SpConv 1 and hotfixes
# see: https://github.com/traveller59/spconv/issues/58
RUN git clone --recursive https://github.com/traveller59/spconv.git /spconv
RUN wget -O hotfixes.zip https://github.com/traveller59/spconv/files/4658204/hotfixes.zip
RUN unzip hotfixes -d /hotfixes
WORKDIR /spconv
RUN git checkout 8da6f967fb9a054d8870c3515b1b44eca2103634 
RUN git submodule update --init --recursive
# needs to be done before we can apply the patches
RUN git config --global user.email "test@test.com"
RUN git config --global user.name "Test"
RUN git am /hotfixes/0001-fix-problem-with-torch-1.4.patch 
RUN git am /hotfixes/0001-Allow-to-specifiy-CUDA_ROOT-directory-and-pick-corre.patch
RUN apt install -y libboost-all-dev cmake
ENV CUDA_ROOT=/usr/local/cuda
RUN pip3 install wheel
RUN python3 setup.py bdist_wheel
WORKDIR /spconv/dist
RUN pip3 install *.whl
WORKDIR /





