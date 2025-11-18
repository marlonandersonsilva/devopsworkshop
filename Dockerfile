# Dockerfile for NOIR Fashion Template
# Multi-stage build for production-ready static site

# Stage 1: Build/Optimization (optional - for future enhancements)
FROM node:20-alpine AS builder
WORKDIR /app
COPY . .
# Placeholder for potential build steps (asset optimization, etc.)
RUN echo "Build stage ready"

# Stage 2: Production server
FROM nginx:alpine
LABEL maintainer="NOIR Fashion Team"
LABEL description="Production-ready NOIR Fashion Template served via Nginx"

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy static files from builder
COPY --from=builder /app /usr/share/nginx/html

# Create non-root user for security
RUN addgroup -g 1001 -S nginx-user && \
    adduser -S -D -H -u 1001 -h /var/cache/nginx -s /sbin/nologin -G nginx-user -g nginx-user nginx-user && \
    chown -R nginx-user:nginx-user /usr/share/nginx/html && \
    chown -R nginx-user:nginx-user /var/cache/nginx && \
    chown -R nginx-user:nginx-user /var/log/nginx && \
    chown -R nginx-user:nginx-user /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown -R nginx-user:nginx-user /var/run/nginx.pid

# Switch to non-root user
USER nginx-user

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost/index.html || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
