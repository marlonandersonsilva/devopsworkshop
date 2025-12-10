FROM nginx:1.28-alpine

# se nginx roda como usuário 'nginx' (uid 101) ou outro, ajuste
RUN mkdir -p /run && chown -R 101:101 /run

# copiar confs etc.
COPY nginx.conf /etc/nginx/nginx.conf

# manter execução em foreground
CMD ["nginx", "-g", "daemon off;"]
