FROM ubuntu:xenial

RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y \
    build-essential \
    cmake \
    font-manager \
    fonts-ipaexfont \
    git \
    language-pack-ja \
    libatlas-base-dev \
    libcurl4-openssl-dev \
    libgtest-dev \
    libopencv-dev \
    libprotoc-dev \
    protobuf-compiler \
    python-opencv \
    python-dev \
    python-numpy \
    python-tk \
    python3-dev \
    unzip \
    wget \
  && rm -rf /var/lib/apt/lists/*

RUN cd /usr/src/gtest && cmake CMakeLists.txt && make && cp *.a /usr/lib && \
    cd /tmp && wget https://bootstrap.pypa.io/get-pip.py && python3 get-pip.py

RUN git clone --recursive https://github.com/apache/incubator-mxnet.git mxnet --branch 1.1.0

RUN pip3 install nose pylint numpy nose-timer requests tqdm

RUN wget --quiet https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 \
  && chmod +x jq-linux64 \
  && mv jq-linux64 /usr/bin/jq

RUN pip3 install \
  attrdict \
  awscli \
  jupyter \
  matplotlib \
  opencv-python \
  pandas \
  pandas_ml \
  pyyaml \
  seaborn \
  sklearn-pandas \
  slackclient

# install compiled mxnet
RUN pip3 install mxnet-mkl==1.1.0

# install mxnet-model-server
RUN git clone https://github.com/awslabs/mxnet-model-server.git --branch v0.2.0 \
  && cd mxnet-model-server \
  && pip3 install -e .

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV MXNET_CUDNN_AUTOTUNE_DEFAULT=1

WORKDIR /mxnet/example/image-classification

COPY common /mxnet/example/image-classification/common/
COPY util /mxnet/example/image-classification/util/
COPY util/inception-resnet-v2.py /mxnet/example/image-classification/symbols/
COPY docker-entrypoint.sh .

ENTRYPOINT ["./docker-entrypoint.sh"]
