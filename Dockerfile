FROM php:7.2-fpm
LABEL maintainer="skrphper@gmail.com"

# Installing dependencies
RUN rm /etc/apt/preferences.d/no-debian-php

# 更新阿里云的stretch版本包源 fucke
RUN echo "deb http://mirrors.aliyun.com/debian stretch main contrib non-free" > /etc/apt/sources.list && \
    echo "deb-src http://mirrors.aliyun.com/debian stretch main contrib non-free" >> /etc/apt/sources.list  && \
    echo "deb http://mirrors.aliyun.com/debian stretch-updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb-src http://mirrors.aliyun.com/debian stretch-updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/debian-security stretch/updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb-src http://mirrors.aliyun.com/debian-security stretch/updates main contrib non-free" >> /etc/apt/sources.list

RUN apt-get update && apt-get install -y \
    wget \
    build-essential \
    mysql-client \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    git \
    libxml2-dev \
    php-soap

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Installing extensions
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl opcache soap bcmath
RUN docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/
RUN docker-php-ext-install gd
RUN pecl install xdebug-2.6.1 \
    && docker-php-ext-enable xdebug

# Installing composer
#RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN wget https://dl.laravel-china.org/composer.phar -O /usr/local/bin/composer && chmod +x /usr/local/bin/composer \
    && composer config -g repo.packagist composer https://packagist.laravel-china.org

# Setting locales
RUN echo fr_FR.UTF-8 UTF-8 > /etc/locale.gen && locale-gen

# Allow container to write on host
RUN usermod -u 1000 www-data

# Changing Workdir
WORKDIR /application

COPY .env.testing /application/.env

# START SERVER
CMD php ./artisan serve --port=8000 --host=0.0.0.0

# EXPOSE PORT
EXPOSE 8000
