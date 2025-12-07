# Dockerfile
FROM nginx:stable-alpine

# remove default conf and add our own
COPY nginx.conf /etc/nginx/conf.d/default.conf

# copy the static files
COPY public /usr/share/nginx/html

# make health endpoint available (nginx serves /)
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s \
  CMD wget -qO- http://localhost/ | grep -q "<title" || exit 1

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
