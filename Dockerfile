FROM nvidia/cuda:10.1-cudnn7-devel-ubuntu16.04

ARG DEBIAN_FRONTEND=noninteractive

# https://gitlab.com/nvidia/container-images/cuda/-/issues/158
RUN apt-key del "7fa2af80" \
&& export this_distro="$(cat /etc/os-release | grep '^ID=' | awk -F'=' '{print $2}')" \
&& export this_version="$(cat /etc/os-release | grep '^VERSION_ID=' | awk -F'=' '{print $2}' | sed 's/[^0-9]*//g')" \
&& apt-key adv --fetch-keys "http://developer.download.nvidia.com/compute/cuda/repos/${this_distro}${this_version}/x86_64/3bf863cc.pub" \
&& apt-key adv --fetch-keys "http://developer.download.nvidia.com/compute/machine-learning/repos/${this_distro}${this_version}/x86_64/7fa2af80.pub"


RUN apt update && apt upgrade -y
RUN apt install -y git wget unzip
RUN apt-get install -y ninja-build

# https://stackoverflow.com/questions/45954528/pip-is-configured-with-locations-that-require-tls-ssl-however-the-ssl-module-in
RUN apt-get install -y build-essential
RUN apt install -y libssl-dev libncurses5-dev libsqlite3-dev libreadline-dev libtk8.6 libgdm-dev libdb4o-cil-dev libpcap-dev

# https://moreless.medium.com/install-python-3-6-on-ubuntu-16-04-28791d5c2167
RUN apt-get install -y zlib1g-dev
WORKDIR /opt
RUN wget https://www.python.org/ftp/python/3.6.9/Python-3.6.9.tgz
RUN tar -xvf Python-3.6.9.tgz
WORKDIR /opt/Python-3.6.9
RUN ./configure
RUN make 
RUN make install
WORKDIR /

# get newer version of cmake
RUN wget https://apt.kitware.com/kitware-archive.sh
RUN chmod +x kitware-archive.sh && ./kitware-archive.sh

RUN pip3 install numpy==1.19.5
RUN pip3 install cython==0.29.24
RUN pip3 install pyyaml==5.1.1
RUN pip3 install tqdm==4.64.0
RUN apt install -y libjpeg-dev zlib1g-dev
RUN pip3 install --upgrade Pillow
RUN pip3 install torch==1.4.0
# RUN pip3 install torch==1.6.0
# RUN pip3 install torch==1.4.0+cu101 -f https://download.pytorch.org/whl/torch_stable.html


ENV PATH=/usr/local/cuda-10.1/bin${PATH:+:${PATH}}
ENV LD_LIBRARY_PATH=/usr/local/cuda-10.1/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
ENV CUDA_HOME=/usr/local/cuda-10.1
ENV CUDA_PATH=/usr/local/cuda-10.1
RUN TORCH_CUDA_ARCH_LIST="6.1"



# https://github.com/facebookresearch/SparseConvNet/issues/96
RUN apt-get install -y libsparsehash-dev

RUN ls
RUN git clone https://github.com/GarrettChristian/JS3C-Net.git
WORKDIR /JS3C-Net/lib
RUN bash compile.sh
WORKDIR /


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



RUN pip3 list

# RUN ldd --version

# RUN git clone https://github.com/facebookresearch/SparseConvNet.git
# WORKDIR /SparseConvNet
# RUN python3 setup.py

# # get newer version of cmake
# RUN wget https://apt.kitware.com/kitware-archive.sh
# RUN chmod +x kitware-archive.sh && ./kitware-archive.sh

# RUN pip3 install torch==1.3.1
# RUN pip3 install cython==0.29.24
# RUN pip3 install pyyaml==5.1.1
# RUN pip3 install tqdm==4.64.0

# https://askubuntu.com/questions/865554/how-do-i-install-python-3-6-using-apt-get
# RUN apt-get install -y software-properties-common
# # RUN add-apt-repository -y ppa:jblgf0/python
# RUN add-apt-repository ppa:jonathonf/python-3.6
# RUN apt-get update
# RUN apt-get install -y python3.6
# RUN pip install --upgrade pip

# RUN apt install -y python3 python3-dev python3-pip

# RUN apt-get install -y software-properties-common
# RUN add-apt-repository ppa:deadsnakes/ppa
# RUN apt-get update
# RUN apt-get install python3.6
# RUN pip3 install --upgrade pip

# # get newer version of cmake
# RUN wget https://apt.kitware.com/kitware-archive.sh
# RUN chmod +x kitware-archive.sh && ./kitware-archive.sh

# RUN pip3 install torch==1.3.1
# RUN pip3 install cython==0.29.24
# RUN pip3 install pyyaml==5.1.1
# RUN pip3 install tqdm==4.64.0

# RUN git clone https://github.com/GarrettChristian/JS3C-Net.git
# WORKDIR /JS3C-Net/lib
# RUN bash compile.sh
# WORKDIR /

# RUN ls /usr/local

# # SpConv
# # need to use SpConv 1 and hotfixes
# # see: https://github.com/traveller59/spconv/issues/58
# RUN git clone --recursive https://github.com/traveller59/spconv.git /spconv
# RUN wget -O hotfixes.zip https://github.com/traveller59/spconv/files/4658204/hotfixes.zip
# RUN unzip hotfixes -d /hotfixes
# WORKDIR /spconv
# RUN git checkout 8da6f967fb9a054d8870c3515b1b44eca2103634 
# RUN git submodule update --init --recursive
# # needs to be done before we can apply the patches
# RUN git config --global user.email "test@test.com"
# RUN git config --global user.name "Test"
# # RUN git am /hotfixes/0001-fix-problem-with-torch-1.4.patch 
# RUN git am /hotfixes/0001-Allow-to-specifiy-CUDA_ROOT-directory-and-pick-corre.patch
# RUN apt install -y libboost-all-dev cmake
# ENV CUDA_ROOT=/usr/local/cuda
# RUN pip3 install wheel
# RUN python3 setup.py bdist_wheel
# WORKDIR /spconv/dist
# RUN pip3 install *.whl
# WORKDIR /





# ---------------------------------------

# FROM nvidia/cuda:10.1-cudnn8-devel-ubuntu16.04


# # https://gitlab.com/nvidia/container-images/cuda/-/issues/158
# RUN apt-key del "7fa2af80" \
# && export this_distro="$(cat /etc/os-release | grep '^ID=' | awk -F'=' '{print $2}')" \
# && export this_version="$(cat /etc/os-release | grep '^VERSION_ID=' | awk -F'=' '{print $2}' | sed 's/[^0-9]*//g')" \
# && apt-key adv --fetch-keys "http://developer.download.nvidia.com/compute/cuda/repos/${this_distro}${this_version}/x86_64/3bf863cc.pub" \
# && apt-key adv --fetch-keys "http://developer.download.nvidia.com/compute/machine-learning/repos/${this_distro}${this_version}/x86_64/7fa2af80.pub"


# RUN apt update && apt upgrade -y
# RUN apt install -y git wget unzip

# # RUN apt install -y python3 python3-dev python3-pip

# RUN apt-get install -y software-properties-common
# RUN add-apt-repository ppa:deadsnakes/ppa
# RUN apt-get update
# RUN apt-get install python3.6
# RUN pip3 install --upgrade pip

# # get newer version of cmake
# RUN wget https://apt.kitware.com/kitware-archive.sh
# RUN chmod +x kitware-archive.sh && ./kitware-archive.sh

# RUN pip3 install torch==1.3.1
# RUN pip3 install cython==0.29.24
# RUN pip3 install pyyaml==5.1.1
# RUN pip3 install tqdm==4.64.0

# RUN git clone https://github.com/GarrettChristian/JS3C-Net.git
# WORKDIR /JS3C-Net/lib
# RUN bash compile.sh
# WORKDIR /

# RUN ls /usr/local

# # SpConv
# # need to use SpConv 1 and hotfixes
# # see: https://github.com/traveller59/spconv/issues/58
# RUN git clone --recursive https://github.com/traveller59/spconv.git /spconv
# RUN wget -O hotfixes.zip https://github.com/traveller59/spconv/files/4658204/hotfixes.zip
# RUN unzip hotfixes -d /hotfixes
# WORKDIR /spconv
# RUN git checkout 8da6f967fb9a054d8870c3515b1b44eca2103634 
# RUN git submodule update --init --recursive
# # needs to be done before we can apply the patches
# RUN git config --global user.email "test@test.com"
# RUN git config --global user.name "Test"
# # RUN git am /hotfixes/0001-fix-problem-with-torch-1.4.patch 
# RUN git am /hotfixes/0001-Allow-to-specifiy-CUDA_ROOT-directory-and-pick-corre.patch
# RUN apt install -y libboost-all-dev cmake
# ENV CUDA_ROOT=/usr/local/cuda
# RUN pip3 install wheel
# RUN python3 setup.py bdist_wheel
# WORKDIR /spconv/dist
# RUN pip3 install *.whl
# WORKDIR /
