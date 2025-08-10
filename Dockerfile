FROM alpine:3.18

# تثبيت الأدوات الضرورية
RUN apk add --no-cache ca-certificates curl bash unzip

WORKDIR /usr/local/bin

# تنزيل أحدث إصدار من Xray
RUN XVER=$(curl -s https://api.github.com/repos/XTLS/Xray-core/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")') \
    && ARCH=64 \
    && URL="https://github.com/XTLS/Xray-core/releases/download/${XVER}/xray-linux-${ARCH}.zip" \
    && echo "جاري تنزيل Xray ${XVER} من ${URL}" \
    && curl -L -o /tmp/xray.zip "$URL" \
    && unzip /tmp/xray.zip -d /usr/local/bin \
    && rm /tmp/xray.zip \
    && chmod +x /usr/local/bin/xray

# نسخ ملف الإعدادات
COPY config.json /etc/xray/config.json

# فتح المنفذ 8080
EXPOSE 8080

# تشغيل Xray
ENTRYPOINT ["/usr/local/bin/xray", "-config", "/etc/xray/config.json"]
