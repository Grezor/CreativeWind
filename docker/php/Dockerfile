FROM php:8.3-apache

COPY php.ini /usr/local/etc/php/conf.d/docker-php-config.ini

RUN apt update -y \
    && apt upgrade -y \
    && apt full-upgrade -y \
    && apt dist-upgrade -y \
    && apt autoremove -y \
    && apt install zip unzip libzip-dev libpq-dev libicu-dev -y \
    libwebp-dev libpng-dev libjpeg-dev libfreetype6-dev cron -y \
    && a2enmod rewrite

RUN pecl install xdebug apcu

RUN docker-php-ext-install zip pdo pgsql pdo_mysql pdo_pgsql opcache intl gd \
    && docker-php-ext-enable xdebug apcu

RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install gd

# Activer le module rewrite d'Apache
RUN a2enmod rewrite

RUN curl -L https://cs.symfony.com/download/php-cs-fixer-v3.phar -o php-cs-fixer \
    && chmod a+x php-cs-fixer \
    && mv php-cs-fixer /usr/local/bin/php-cs-fixer

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer
COPY conf.d/xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
# COPY conf.d/error_reporting.ini /usr/local/etc/php/conf.d/error_reporting.ini
COPY conf.d/opcache.ini /usr/local/etc/php/conf.d/opcache.ini

COPY etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf

WORKDIR /var/www/html