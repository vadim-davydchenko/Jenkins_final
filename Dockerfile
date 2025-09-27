FROM nginx:1.29-alpine-slim
COPY health.html /usr/share/nginx/html/health
EXPOSE 80
