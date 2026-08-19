FROM alpine:3.23

RUN apk add --no-cache \
    php84 \
    php84-fpm \
    php84-mysqli \
    php84-curl \
    php84-dom \
    php84-exif \
    php84-fileinfo \
    php84-mbstring \
    php84-openssl \
    php84-xml \
    php84-zip \
    php84-phar \
    php84-iconv \
    php84-tokenizer \
    curl \
    mariadb-client

RUN sed -i 's/^memory_limit = .*/memory_limit = 512M/' /etc/php84/php.ini
RUN curl -o /usr/local/bin/wp \
    https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

COPY conf/www.conf /etc/php84/php-fpm.d/www.conf
COPY tools/setup.sh /setup.sh

RUN chmod +x /setup.sh

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["/setup.sh"]