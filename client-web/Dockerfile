FROM nginx:alpine

# Copier les fichiers HTML/JS générés dans nginx
COPY client-web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
