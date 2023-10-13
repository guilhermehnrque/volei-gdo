FROM php:8.1.4-fpm-alpine

ARG LOCAL_USER=root
ARG USER_ID=0
ARG GROUP_ID=0

WORKDIR /var/www/html

# Install dev dependencies
RUN apk update && apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    libzip-dev \
    libxml2-dev \
    freetype \
    libjpeg-turbo \
    libpng \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev

RUN apk add --update bash zip unzip curl sqlite nginx supervisor php8 \
    php8-common \
    php8-fpm \
    php8-pdo \
    php8-opcache \
    php8-zip \
    php8-phar \
    php8-iconv \
    php8-cli \
    php8-curl \
    php8-openssl \
    php8-mbstring \
    php8-tokenizer \
    php8-fileinfo \
    php8-json \
    php8-xml \
    php8-xmlwriter \
    php8-simplexml \
    php8-dom \
    php8-pdo_mysql \
    php8-pdo_sqlite \
    php8-tokenizer \
    php8-pecl-redis \
    php8-xdebug \
    php8-soap \
    php8-pcntl \
    php8-bcmath \
    php8-exif

RUN echo http://dl-2.alpinelinux.org/alpine/edge/community/ >> /etc/apk/repositories

RUN docker-php-ext-install mysqli pdo pdo_mysql zip pcntl soap bcmath exif

RUN docker-php-ext-configure gd \
      --with-freetype=/usr/include/ \
      --with-jpeg=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-enable gd

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN if [ ! "$LOCAL_USER" = "root" ]; \
    then addgroup -g ${GROUP_ID} ${LOCAL_USER} \
    &&  adduser -u ${USER_ID} -S ${LOCAL_USER} -G ${LOCAL_USER}; \
    else echo "No user to add."; fi

USER ${LOCAL_USER}

EXPOSE 9000
CMD ["php-fpm"]
