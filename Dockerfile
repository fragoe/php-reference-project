FROM php:7.4-fpm-buster as base

# Install apps and libraries
RUN apt update
RUN apt install -y libxml2 libxml2-dev zlib1g-dev libzip-dev libssh2-1-dev git zip openssl libssl-dev mc

# Install PHP extensions
RUN pecl install ssh2-1.2 && docker-php-ext-enable ssh2
RUN docker-php-ext-install  dom \
                            sockets \
                            soap \
                            pdo_mysql \
                            zip \
                            bcmath

# Add web user
RUN groupadd -r app -g 1000 && useradd -u 1000 -r -g app -m -d /home/app -s /bin/bash -c "App user" app

# Install Composer
WORKDIR /tmp
RUN curl --silent --show-error https://getcomposer.org/installer | php
RUN mv /tmp/composer.phar /usr/bin/composer
RUN mkdir /app && chown app:app /app
RUN sed -i 's/www-data/app/g' /usr/local/etc/php-fpm.d/www.conf
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
RUN sed -i 's/memory_limit\ =\ 128M/memory_limit\ =\ \-1/g' /usr/local/etc/php/php.ini
WORKDIR /app
USER app
CMD ["sh", "-c", "composer symfony-scripts --no-interaction ; php-fpm -F"]

FROM base AS dev-linux
USER root
WORKDIR /tmp
RUN yes | pecl install xdebug \
    && echo "zend_extension=xdebug.so" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.mode = debug" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.start_with_request = yes" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.start_upon_error = yes" >> /usr/local/etc/php/conf.d/xdebug.ini
RUN sed -i 's/max_execution_time\ =\ 30/max_execution_time\ =\ 90/g' /usr/local/etc/php/php.ini
USER app
WORKDIR /app

FROM dev-linux AS dev-macos
USER root
RUN echo "xdebug.client_host = host.docker.internal" >> /usr/local/etc/php/conf.d/xdebug.ini
USER app
WORKDIR /app
