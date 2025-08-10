FROM alpine:3.18

# Install required packages
RUN apk add --no-cache ca-certificates curl unzip

# Set working directory
WORKDIR /app

# Download and install Xray (stable version)
RUN curl -L -o xray.zip "https://github.com/XTLS/Xray-core/releases/download/v1.8.4/Xray-linux-64.zip" && \
    unzip xray.zip && \
    chmod +x xray && \
    rm xray.zip

# Copy configuration file
COPY config.json /app/config.json

# Create startup script
RUN echo '#!/bin/sh' > /app/start.sh && \
    echo 'exec /app/xray run -config /app/config.json' >> /app/start.sh && \
    chmod +x /app/start.sh

# Set environment variables
ENV PORT=8080

# Expose port
EXPOSE 8080

# Create non-root user for security
RUN adduser -D -s /bin/sh appuser && \
    chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Start the application
CMD ["/app/start.sh"]
