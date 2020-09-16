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
  libpcre3-dev \
  nano \
  htop \
  zip \
  unzip \
  git \
  supervisor \
  g++ \
  zlib1g-dev \
  libjpeg-dev \
  libmagickwand-dev \
  libpng-dev \
  libgif-dev \
  libtiff-dev \
  libz-dev \
  libpq-dev \
  libcurl4-openssl-dev \
  libaprutil1-dev \
  libssl-dev \
  libicu-dev \
  libxml2-dev \
  sysvbanner \
  libzip-dev \
  libjpeg62-turbo-dev \
  libfreetype6-dev \
  imagemagick \
  ghostscript \
  jpegoptim \ 
  optipng \
  pngquant \
  libnss3-dev \
  ca-certificates \
  fonts-liberation \
  libappindicator3-1 \
  libasound2 \
  libatk-bridge2.0-0 \
  libatk1.0-0 \
  libc6 \
  libcairo2 \
  libcups2 \
  libdbus-1-3 \
  libexpat1 \ 
  libfontconfig1 \
  libgbm1 \
  libgcc1 \
  libglib2.0-0 \ 
  libgtk-3-0 \
  libnspr4 \
  libnss3 \
  libpango-1.0-0 \
  libpangocairo-1.0-0 \
  libstdc++6 \
  libx11-6 \
  libx11-xcb1 \
  libxcb1 \ 
  libxcomposite1 \
  libxcursor1 \ 
  libxdamage1 \
  libxext6 \
  libxfixes3 \
  libxi6 \
  libxrandr2 \
  libxrender1 \
  libxss1 \
  libxtst6 \
  lsb-release \
  wget \
  xdg-utils \
  libc-client-dev \
  libjpeg-dev \
  gifsicle && apt-get clean && rm -rf /var/lib/apt/lists/* &&  rm -rf /tmp/library-scripts \
  apt-get purge --auto-remove -o APT::AutoRemove::RecommendsImportant=false

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
