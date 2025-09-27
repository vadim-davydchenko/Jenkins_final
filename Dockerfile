FROM nginx:1.25-alpine
COPY health.html /usr/share/nginx/html/health
EXPOSE 80
