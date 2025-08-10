FROM alpine:3.18

RUN apk add --no-cache ca-certificates curl bash unzip

WORKDIR /usr/local/bin

# Download latest Xray
RUN XVER=$(curl -s https://api.github.com/repos/XTLS/Xray-core/releases/latest | grep -oP '\\"tag_name\\": \\"\\K(.*)(?=\\")') \
    && ARCH=64 \
    && URL="https://github.com/XTLS/Xray-core/releases/download/${XVER}/Xray-linux-${ARCH}.zip" \
    && echo "Downloading Xray ${XVER} from ${URL}" \
    && curl -L -o /tmp/xray.zip "$URL" \
    && unzip /tmp/xray.zip -d /usr/local/bin \
    && rm /tmp/xray.zip

COPY config.json /etc/xray/config.json

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/xray", "-config", "/etc/xray/config.json"]
