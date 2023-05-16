FROM ubuntu:latest
RUN apt-get update -y \
  && apt-get install -y --no-install-recommends build-essential gcc libc-dev make bison flex vim 