FROM alpine:3.18

# Install required packages
RUN apk add --no-cache \
    ca-certificates \
    curl \
    unzip \
    tzdata \
    && update-ca-certificates

# Set timezone
ENV TZ=UTC

# Create xray user and directories
RUN addgroup -g 1000 xray && \
    adduser -u 1000 -G xray -s /bin/sh -D xray && \
    mkdir -p /var/log/xray /etc/xray /usr/local/share/xray && \
    chown -R xray:xray /var/log/xray /etc/xray /usr/local/share/xray

WORKDIR /etc/xray

# Download and install latest Xray
ARG XRAY_VERSION=latest
RUN if [ "$XRAY_VERSION" = "latest" ]; then \
        XRAY_VERSION=$(curl -s https://api.github.com/repos/XTLS/Xray-core/releases/latest | grep tag_name | cut -d '"' -f 4); \
    fi && \
    curl -L -o xray-linux-64.zip "https://github.com/XTLS/Xray-core/releases/download/${XRAY_VERSION}/Xray-linux-64.zip" && \
    unzip xray-linux-64.zip && \
    install -m 755 xray /usr/local/bin/xray && \
    install -m 644 geoip.dat /usr/local/share/xray/ && \
    install -m 644 geosite.dat /usr/local/share/xray/ && \
    rm -rf xray-linux-64.zip xray geoip.dat geosite.dat

# Copy configuration
COPY config.json /etc/xray/config.json
RUN chown xray:xray /etc/xray/config.json

# Create startup script
RUN cat > /usr/local/bin/start-xray.sh << 'EOF'
#!/bin/sh
set -e

# Create log directory if it doesn't exist
mkdir -p /var/log/xray
chown xray:xray /var/log/xray

# Start Xray
exec /usr/local/bin/xray run -config /etc/xray/config.json
EOF

RUN chmod +x /usr/local/bin/start-xray.sh

# Switch to xray user
USER xray

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

ENTRYPOINT ["/usr/local/bin/start-xray.sh"]
