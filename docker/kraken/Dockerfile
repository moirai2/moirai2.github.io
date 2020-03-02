FROM ubuntu
RUN apt update \
&& apt install -y --no-install-recommends \
bedtools \
&& apt -y clean \
&& rm -rf /var/lib/apt/lists/*
