FROM golang:latest
ENV CGO_ENABLED 0

RUN apk update && apk add bash inotify-tools
RUN go get github.com/go-delve/delve/cmd/dlv


COPY --chmod= ./entrypoint.sh /opt
RUN chmod +x /opt/entrypoint.sh

ENTRYPOINT [ "/opt/entrypoint.sh" ]