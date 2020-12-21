FROM golang:latest as builder
ENV GOPATH="/go:/opt"
WORKDIR /opt
COPY . .
RUN go mod download
RUN go build -o /opt/server ./src/main/main.go
RUN chmod +x /opt/server

FROM alpine:latest
WORKDIR /opt
COPY --from=builder /opt/server /opt/server
RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2
ENTRYPOINT /opt/server