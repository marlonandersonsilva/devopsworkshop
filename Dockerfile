FROM nginx:1.28-alpine


# se você tem config customizada, copie aqui
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./dist /usr/share/nginx/html

# cria /run e dá ownership ao usuário nginx (usuário 'nginx' existe na image oficial)
RUN mkdir -p /run \
    && touch /run/nginx.pid \
    && chown -R nginx:nginx /run

USER nginx

# entrypoint padrão do nginx: mantém em foreground
CMD ["nginx", "-g", "daemon off;"]
