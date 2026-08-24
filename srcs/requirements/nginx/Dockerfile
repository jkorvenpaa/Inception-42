FROM alpine:3.23

RUN apk add --no-cache nginx openssl

RUN mkdir -p /etc/nginx/ssl \
    && openssl req -x509 -nodes \
        -newkey rsa:2048 \
        -days 365 \
        -keyout /etc/nginx/ssl/nginx.key \
        -out /etc/nginx/ssl/nginx.crt \
        -subj "/CN=localhost"

COPY conf/nginx.conf /etc/nginx/nginx.conf

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]