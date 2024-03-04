# Use PHP-FPM Alpine image
FROM php:fpm-alpine3.19

# Set working directory
WORKDIR /app

# Install PHP extensions and other dependencies
RUN apk --no-cache add \
        bash \
        git \
        libjpeg-turbo-dev \
        libpng-dev \
        libzip-dev \
        linux-headers \
        zip \
        unzip \
        zlib-dev \
        libxml2-dev \
        icu-dev \
        libxslt-dev \
        g++ \
        make \
        autoconf 

RUN docker-php-ext-install -j$(nproc) gd pdo pdo_mysql zip intl soap xsl opcache

# Install XDebug
COPY ./xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
RUN pecl install xdebug-3.3.1
RUN docker-php-ext-enable xdebug

COPY . /app/

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
ENV COMPOSER_ALLOW_SUPERUSER=1

#Install Symfony dependencies
RUN composer install --no-dev --no-scripts --optimize-autoloader
ENV COMPOSER_ALLOW_SUPERUSER=0

# Start PHP-FPM
CMD php-fpm