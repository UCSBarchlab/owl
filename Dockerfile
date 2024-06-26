FROM debian:bookworm-backports

RUN apt update && \
    apt install -y \
    bash \
    build-essential \
    cmake \
    curl \
    cvc4 \
    git \
    less \
    nano \
    python3-full \
    python3-pip \
    python3-pyparsing \
    racket \
    screen \
    software-properties-common \
    time \
    vim \
    z3 \
    bison \
    flex \
    libz3-dev \
    libgoogle-glog-dev

WORKDIR /opt
COPY . /opt
RUN mkdir /opt/results

# Build boolector
RUN git clone https://github.com/boolector/boolector && \
	cd boolector && \
	./contrib/setup-lingeling.sh && \
	./contrib/setup-btor2tools.sh && \
	./configure.sh && \
	cd build && \
	make install 

# Install PyRTL
RUN rm -rf /usr/lib/python3.11/EXTERNALLY-MANAGED
RUN git clone https://github.com/pllab/PyRTL.git && \
	cd PyRTL && \
	git checkout function-holes && \
	pip3 install .


# Install ILAng
RUN git clone https://github.com/PrincetonUniversity/ILAng.git && \
    cd ILAng && \
    mkdir -p build && cd build && \
    cmake -DILANG_BUILD_TEST=OFF -DILANG_INSTALL_DEV=ON .. && \
    make

## Build ila-to-rosette
RUN cd /opt/ila-to-rosette && mkdir -p build && cd build && \
    cmake -Dilang_DIR=/opt/ILAng/build -Dnlohmann_json_DIR=/opt/ILAng/build/extern/json -Dverilogparser_DIR=/opt/ILAng/build/extern/vlog-parser -Dvcdparser_DIR=/opt/ILAng/build/extern/vcd-parser -Dsmtparser_DIR=/opt/ILAng/build/extern/smt-parser -Dfmt_DIR=/opt/ILAng/build/extern/fmt .. && \
    make


# Install Rosette
RUN raco pkg install --auto rosette

# Install Oyster
RUN cd /opt && raco pkg install oyster/
