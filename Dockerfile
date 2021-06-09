FROM golang:latest
ENV CGO_ENABLED 0

RUN apt-get update && apt-get install bash inotify-tools
RUN go get github.com/go-delve/delve/cmd/dlv


COPY ./entrypoint.sh /opt
RUN chmod +x /opt/entrypoint.sh

ENTRYPOINT [ "/opt/entrypoint.sh" ]