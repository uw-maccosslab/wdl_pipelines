FROM openjdk:8-jre

MAINTAINER "Aaron Maurais -- MacCoss Lab"

RUN apt-get update && \
    apt-get -y upgrade && \ 
    apt-get -y install build-essential cmake libgomp1 && \
    apt-get clean

# Create the directories
RUN mkdir /code \
    && mkdir /data

# Install a version of percolator that actually works
ENV PERCOLATOR_VERSION='3-01'
RUN cd /code && mkdir percolator && cd percolator \
    && wget https://github.com/percolator/percolator/archive/refs/tags/rel-"$PERCOLATOR_VERSION".tar.gz \
    && tar xf rel-"$PERCOLATOR_VERSION".tar.gz \
    && cd percolator-rel-"$PERCOLATOR_VERSION" \
    && cmake . && make && cp src/percolator /usr/local/bin

# Download EncyclopeDIA 
# ENV VERSION=2.12.30
ENV VERSION=3.0.0-SNAPSHOT
# RUN cd /code; wget -O "encyclopedia-$VERSION-executable.jar" "https://bitbucket.org/searleb/encyclopedia/downloads/encyclopedia-$VERSION-executable.jar"
COPY encyclopedia-3.0.0-SNAPSHOT-executable.jar /code

WORKDIR /data

