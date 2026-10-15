FROM ubuntu:latest
LABEL authors="kevyn"

ENTRYPOINT ["top", "-b"]