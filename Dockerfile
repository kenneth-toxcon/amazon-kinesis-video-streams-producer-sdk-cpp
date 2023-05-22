FROM ubuntu:18.04

# Update system and install prerequisites in one layer
RUN apt-get update -qq && apt-get -y install \
    git \
    curl \    
    build-essential \
    wget \
	libssl-dev \
	libcurl4-openssl-dev \
	liblog4cplus-dev \
	libgstreamer1.0-dev \
	libgstreamer-plugins-base1.0-dev \
	streamer1.0-plugins-base-apps \
	gstreamer1.0-plugins-bad \
	gstreamer1.0-plugins-good \
	gstreamer1.0-plugins-ugly \
	gstreamer1.0-tools

# Pre-built make
WORKDIR /tmp
RUN curl -sSL https://github.com/Kitware/CMake/releases/download/v3.10.0/cmake-3.10.0.tar.gz -o cmake-3.10.0.tar.gz \
    && tar -zxvf cmake-3.10.0.tar.gz \
    && cd cmake-3.10.0 \
    && ./bootstrap \
    && make -j 4 \
    && make install

# Clone the repo
WORKDIR /tmp
RUN git clone https://github.com/awslabs/amazon-kinesis-video-streams-producer-sdk-cpp.git

# Copy the modified sample file into the repo, replacing the original
COPY ./src/kvs_gstreamer_audio_video_sample.cpp /tmp/amazon-kinesis-video-streams-producer-sdk-cpp/samples

# Build the project
WORKDIR /tmp/amazon-kinesis-video-streams-producer-sdk-cpp/build
RUN cmake .. -DBUILD_GSTREAMER_PLUGIN=TRUE -DBUILD_TEST=FALSE && \
    make

# Setup the working directory for the container with video file and access
WORKDIR /home/workdir
RUN mkdir videos/
COPY ./videos/* videos/

# Set the default command for the container
CMD ["/bin/bash"]
