FROM golang:1.12 as build

ENV GO111MODULE on
ENV GOPROXY "https://goproxy.io"

WORKDIR /opt
RUN mkdir etcdkeeper
ADD . /opt/etcdkeeper
WORKDIR /opt/etcdkeeper/src/etcdkeeper

RUN go mod download \
    && go build -o etcdkeeper.bin main.go


FROM alpine:3.10

ENV HOST="0.0.0.0"
ENV PORT="8080"

ENV ETCD_VERSION="3"
ENV ETCD_ENDPOINT="127.0.0.1:2379"



# RUN apk add --no-cache ca-certificates

RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

WORKDIR /opt/etcdkeeper
COPY --from=build /opt/etcdkeeper/src/etcdkeeper/etcdkeeper.bin .
ADD assets assets

EXPOSE ${PORT}

ENTRYPOINT ./etcdkeeper.bin -h $HOST -p $PORT -apiversion $ETCD_VERSION -endpoint $ETCD_ENDPOINT 