ARG PHP_VERSION=7.4

ARG PHP_MEMORY_LIMIT=-1
ARG PHP_INI_DIR=/usr/local/etc/php/php.ini

FROM php:${PHP_VERSION}-fpm-alpine

RUN apk add --no-cache wget gnupg

RUN apk add --no-cache \
                acl \
                file \
                gettext \
                git \
                mariadb-client \
        ;
ARG APCU_VERSION=5.1.17
RUN set -eux; \
        apk add --no-cache --virtual .build-deps \
                $PHPIZE_DEPS \
                coreutils \
                freetype-dev \
                icu-dev \
                libjpeg-turbo-dev \
                libpng-dev \
                libtool \
                libwebp-dev \
                libzip-dev \
                mariadb-dev \
                libmemcached-dev \
                wv \
                gmp-dev \
                zlib-dev \
        ; \
        docker-php-ext-configure gd --with-jpeg=/usr/include/ --with-webp=/usr/include --with-freetype=/usr/include/; \

        docker-php-ext-install -j$(nproc) \
                exif \
                gd \
                intl \
                pdo_mysql \
                zip \
                gmp \
        ; \
        pecl install \
                apcu-${APCU_VERSION} \
        ; \
        pecl clear-cache; \
        docker-php-ext-enable \
                apcu \
                opcache \
        ; \
        \
        runDeps="$( \
                scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
                        | tr ',' '\n' \
                        | sort -u \
                        | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
        )"; \
        apk add --no-cache --virtual .sylius-phpexts-rundeps $runDeps; \
        \
        apk del .build-deps

RUN set -eux \
    & apk add \
        --no-cache \
        nodejs \
        npm \
        yarn

RUN set -eux \
    & npm install -g gulp

VOLUME /var/run/php

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV PATH="${PATH}:/root/.composer/vendor/bin"

