from python:3.9-alpine

MAINTAINER "Aaron Maurais -- MacCoss Lab"

RUN apk add --no-cache bash xmlstarlet zip

ADD wdl_array_tools tsv_to_gct /usr/bin

WORKDIR /data

CMD ["wdl_array_tools"]

