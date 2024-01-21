FROM mcr.microsoft.com/devcontainers/php:1-${templateOption:phpVersion}-${templateOption:imageVariant}

RUN apt-get update && apt-get install -y \
    libzip-dev \
    git \
    unzip \
    wget \
    libfreetype6-dev \
    libicu-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libxslt1-dev \
    mariadb-client \
    sendmail-bin \
    sendmail \
    sudo \
    redis \
    vim \
    curl \
    libzip-dev \
    unzip \
    wget \
    libmagickwand-dev \
    imagemagick \ 
    libjpeg-dev \
    && apt clean

# configure php
RUN  docker-php-ext-install -j$(nproc) gd \
        && docker-php-ext-install \
          dom \
          intl \
          gd \
          pdo_mysql \
          xsl \
          zip \
          soap \
          bcmath \
          calendar \
          sockets \
          posix \
          pcntl \
        && docker-php-ext-configure sockets \
        && docker-php-ext-configure gd --with-jpeg --with-freetype \
        && docker-php-ext-install gd

# install imagick
RUN pecl install imagick

# composer dependencies
RUN curl https://getcomposer.org/download/2.1.12/composer.phar --output /usr/local/bin/composer
RUN chmod +x /usr/local/bin/composer
RUN composer --version

# n98-magerun2
RUN curl https://files.magerun.net/n98-magerun2.phar --output /usr/local/bin/n98
RUN chmod +x /usr/local/bin/n98
RUN n98 --version

# # configuration
RUN echo "extension=imagick.so" > /usr/local/etc/php/conf.d/imagick.ini
RUN echo 'memory_limit = 2G' >> /usr/local/etc/php/php.ini
RUN echo 'max_input_vars = 10000' >> /usr/local/etc/php/php.ini
RUN echo 'memory_limit = -1' >> /usr/local/etc/php/conf.d/memory_limit.ini

USER vscode
# magento cloud
RUN curl -sS https://accounts.magento.cloud/cli/installer | php
RUN echo "export PATH=$PATH:$HOME/.magento-cloud/bin" >> ~/.bash_profile
