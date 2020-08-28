FROM php:7.4-apache

EXPOSE 80

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
  && apt-get install -y curl \ 
  sudo \
  software-properties-common \
  build-essential \
  apache2 \
  tcl \
  cron \
  bzip2 \
  tidy \
  wget \
  less \
  nano \
  htop \
  zip \
  unzip \
  git \
  libwebp-dev \
  webp \
  libwebp6 \
  graphicsmagick \
  csstidy \
  g++ \
  zlib1g-dev \
  libjpeg-dev \
  libmagickwand-dev \
  libpng-dev \
  libgif-dev \
  libtiff-dev \
  libz-dev \
  inetutils-ping \
  libpq-dev \
  libcurl4-openssl-dev \
  libaprutil1-dev \
  libssl-dev \
  libicu-dev \
  libldap2-dev \
  libmemcached-dev \
  libxml2-dev \
  libzip-dev \
  mariadb-client \
  libwebp-dev \
  libjpeg62-turbo-dev \
  libxpm-dev \
  libfreetype6-dev \
  imagemagick \
  ghostscript \
  jpegoptim \ 
  optipng \
  pngquant \
  libc-client-dev \
  libjpeg-dev \
  gifsicle \
  groff \
  python \
  python-setuptools \
  python-pip && apt-get clean -y && rm -rf /var/lib/apt/lists/* &&  rm -rf /tmp/library-scripts

RUN pip install awscli

RUN apt-get update
RUN apt-get -y install curl gnupg
RUN curl -sL https://deb.nodesource.com/setup_11.x  | bash -
RUN apt-get -y install nodejs

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
  mysqli \
  opcache \
  zip

RUN printf "\n" | printf "\n" | pecl install redis \
  ; \
  pecl install imagick \
  apcu \
  mailparse \
  memcached

RUN docker-php-ext-enable imagick \
  bcmath \
  redis \
  opcache \
  mailparse \
  apcu \
  memcached

# Enable apache modules
RUN a2enmod setenvif \
  headers \
  deflate \
  filter \
  expires \
  rewrite \
  include \
  ext_filter

COPY optimize.conf /etc/apache2/conf-available/optimize.conf

RUN a2enconf optimize

# set recommended opcache settings
RUN { \
  echo 'opcache.enable=1' \
  echo 'opcache.validate_timestamps=0' \
  echo 'opcache.memory_consumption=768'; \
  echo 'opcache.interned_strings_buffer=32'; \
  echo 'opcache.max_accelerated_files=99999'; \
  echo 'opcache.revalidate_freq=2'; \
  echo 'opcache.max_wasted_percentage=10' \
  echo 'opcache.fast_shutdown=1'; \
  } > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN curl -s https://getcomposer.org/installer | php

RUN mv composer.phar /usr/local/bin/composer

RUN composer global require laravel/installer

RUN export PATH="$PATH:$HOME/.composer/vendor/bin"
