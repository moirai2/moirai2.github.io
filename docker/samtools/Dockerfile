FROM ubuntu
RUN apt update \
&& apt install -y --no-install-recommends \
samtools \
bedtools \
&& apt -y clean \
&& rm -rf /var/lib/apt/lists/*
