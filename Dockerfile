FROM nginx:1.29-alpine-slim
RUN apk update && apk upgrade --no-cache && rm -rf /var/cache/apk/*
COPY health.html /usr/share/nginx/html/health
EXPOSE 80
