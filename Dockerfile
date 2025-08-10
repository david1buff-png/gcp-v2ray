FROM alpine:3.18

RUN apk add --no-cache ca-certificates

WORKDIR /root

COPY xray /root/xray
COPY config.json /root/config.json

RUN chmod +x /root/xray

EXPOSE 8080

ENTRYPOINT ["/root/xray", "-config", "/root/config.json"]
