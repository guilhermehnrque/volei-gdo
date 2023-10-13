FROM php:8.2-fpm

WORKDIR /app

# Install dev dependencies
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libzip-dev \
    && docker-php-ext-install pdo pdo_mysql \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install zip

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN rm -rf /var/www/html && \
    ln -s /app /var/www/html

COPY --chown=www-data:www-data ./app ./

RUN chown -R www-data:www-data /app/storage

EXPOSE 9000

CMD ["php-fpm"]

#ENTRYPOINT ["/bin/sh", "/docker-entrypoint.sh"]