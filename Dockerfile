FROM nvidia/cuda:12.3.1-devel-ubuntu20.04

ENV DEBIAN_FRONTEND noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    git \
    build-essential \
    cmake \
    autoconf \
    automake \
    libtool \
    pkg-config \
    openjdk-17-jdk \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Set Java environment variables
ENV JAVA_HOME /usr/lib/jvm/java-17-openjdk-amd64
ENV PATH $JAVA_HOME/bin:$PATH

# Install BEAGLE
RUN git clone --depth=1 --branch="v3.1.2" https://github.com/beagle-dev/beagle-lib.git \
    && cd beagle-lib \
    && sed -i 's/compute_30/compute_70/' configure.ac \
    && ./autogen.sh \
    && ./configure --prefix=/usr/local \
    && make install \
    && cd .. \
    && rm -rf beagle-lib

# Install beast2 and set up classpath
RUN wget https://github.com/CompEvol/beast2/releases/download/v2.7.6/BEAST.v2.7.6.Linux.x86.tgz \
    && tar -xzf BEAST.v2.7.6.Linux.x86.tgz \
    && rm BEAST.v2.7.6.Linux.x86.tgz \
    && mv beast /usr/local/ \
    && ln -s /usr/local/beast/bin/beast /usr/local/bin/beast \
    && ln -s /usr/local/beast/bin/packagemanager /usr/local/bin/packagemanager \
    && mkdir -p /usr/local/beast/packages \
    && packagemanager -dir /usr/local/beast/packages -add phylonco \
    && mkdir -p /usr/local/beast/packages/rootfreqs

COPY addons/rootfreqs.addon.v0.0.2.zip /usr/local/beast/packages/rootfreqs

RUN unzip /usr/local/beast/packages/rootfreqs/rootfreqs.addon.v0.0.2.zip -d /usr/local/beast/packages/rootfreqs 


ENV CLASSPATH /usr/local/beast/lib/*:

# Set up entrypoint
CMD ["/bin/bash"]
