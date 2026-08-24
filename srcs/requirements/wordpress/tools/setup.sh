#!/bin/sh

set -e

DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

until mariadb \
    --connect-timeout=2 \
    -h mariadb \
    -u "${MYSQL_USER}" \
    -p"${DB_PASSWORD}" \
    "${MYSQL_DATABASE}" \
    -e "SELECT 1;" \
    >/dev/null
do
    echo "Waiting for MariaDB..."
    sleep 2
done
echo "MariaDB is ready."

if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Installing WordPress..."
    wp core download \
        --path=/var/www/html \
        --allow-root

    wp config create \
        --path=/var/www/html \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost="mariadb:3306" \
        --allow-root

    wp core install \
        --path=/var/www/html \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="owner@example.com" \
        --skip-email \
        --allow-root

    wp user create \
        "${WP_USER}" \
        "user@example.com" \
        --path=/var/www/html \
        --role=author \
        --user_pass="${WP_USER_PASSWORD}" \
        --allow-root

    chown -R nobody:nobody /var/www/html
    echo "WordPress setup complete."
else
    echo "WordPress already installed."
fi

mkdir -p /run/php

echo "Starting PHP-FPM..."

exec php-fpm84 -F