FROM php:7.4-fpm



RUN apt-get update && \
    apt-get install -y \
    autoconf pkg-config libssl-dev \
    curl libpng-dev libonig-dev \
    libxml2-dev zip unzip \
    nano git libpq-dev

RUN pecl install mongodb

RUN docker-php-ext-install bcmath
RUN echo "extension=mongodb.so" >> /usr/local/etc/php/conf.d/mongodb.ini

# Install Laravel dependencies
RUN apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev


RUN docker-php-ext-install iconv mcrypt mbstring \
    && docker-php-ext-install zip \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd

RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql

RUN docker-php-ext-install \
    pdo_mysql \
    pdo pdo_pgsql pgsql \
    mbstring \
    exif \
    bcmath \
    pcntl \
    gd

# install composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# add artisan auto completion
ADD docker/artisan/autocomplete.txt /autocomplete.txt
RUN touch /root/.bashrc && cat /autocomplete.txt >> /root/.bashrc

RUN apt autoremove
WORKDIR /var/www