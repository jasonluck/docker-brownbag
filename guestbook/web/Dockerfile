FROM nginx

#Load our nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

#Load our application static content
COPY content /usr/share/nginx/html

#Install curl for HEALTHCHECK
RUN apt update \
    && apt-get install -y curl


HEALTHCHECK --interval=30s --timeout=10s CMD curl --fail http://localhost || exit 1