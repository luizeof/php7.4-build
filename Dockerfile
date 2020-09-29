FROM php:7.4-apache

EXPOSE 80

ENV COMPOSER_MEMORY_LIMIT -1

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
  && apt-get install -y curl \ 
  sudo \
  software-properties-common \
  build-essential \
  apache2 \
  cron \
  bzip2 \
  wget \
  gnupg \
  htop \
  zip \
  unzip \
  git \
  supervisor \
  zlib1g-dev \
  libz-dev \
  libcurl4-openssl-dev \
  libssl-dev \
  libicu-dev \
  libxml2-dev \
  libzip-dev \
  imagemagick \
  libnss3-dev \
  ca-certificates \
  libcairo2 \
  libgcc1 \
  libglib2.0-0 \ 
  libnss3 \
  libpango-1.0-0 \
  libpangocairo-1.0-0 \
  libstdc++6 \
  lsb-release \
  wget \
  libc-client-dev \
  gifsicle && apt-get clean && rm -rf /var/lib/apt/lists/* &&  rm -rf /tmp/library-scripts \
  apt-get purge

RUN apt-get update
RUN curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
RUN apt-get update
RUN apt-get install -y nodejs

# Installing Apache mod-pagespeed
RUN curl -o /home/mod-pagespeed-beta_current_amd64.deb https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-beta_current_amd64.deb
RUN dpkg -i /home/mod-pagespeed-*.deb
RUN apt-get -f install

RUN	docker-php-ext-configure gd --with-freetype --with-jpeg

RUN docker-php-ext-install -j "$(nproc)" \
  bcmath \
  exif \
  gd \
  pdo \
  intl \
  xml \
  pdo_mysql \
  soap \
  pcntl \
  mysqli \
  opcache \
  zip

RUN printf "\n" | printf "\n" | pecl install redis \
  ; \
  pecl install imagick \
  apcu \
  mailparse

RUN docker-php-ext-enable imagick \
  bcmath \
  redis \
  opcache \
  mailparse \
  apcu

# Enable apache modules
RUN a2enmod setenvif \
  headers \
  deflate \
  filter \
  expires \
  rewrite \
  include \
  ext_filter

RUN echo '\
  opcache.enable=1\n\
  opcache.memory_consumption=512\n\
  opcache.interned_strings_buffer=32\n\
  opcache.load_comments=Off\n\
  opcache.revalidate_freq=0\n\
  opcache.validate_timestamps=0\n\
  opcache.enable_file_override=1\n\
  opcache.max_accelerated_files=999999\n\
  opcache.save_comments=Off\n\
  ' >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini

COPY optimize.conf /etc/apache2/conf-available/optimize.conf

RUN a2enconf optimize

RUN curl -s https://getcomposer.org/installer | php

RUN mv composer.phar /usr/local/bin/composer

RUN composer global require laravel/installer

RUN export PATH="$PATH:$HOME/.composer/vendor/bin"
