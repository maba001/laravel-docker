FROM ubuntu:16.04
MAINTAINER Alex

ENV DEBIAN_FRONTEND noninteractive

# upgrade the container
RUN apt-get update && \
    apt-get upgrade -y


# install gosu
ENV GOSU_VERSION 1.9
RUN set -x \
    && apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
    && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true 


# install some prerequisites
RUN apt-get install -y \
      software-properties-common \
      curl \
      build-essential \
      dos2unix \
      gcc \
      git \
      libmcrypt4 \
      libpcre3-dev \
      memcached \
      make \
      python2.7-dev \
      python-pip \
      re2c \
      unattended-upgrades \
      whois \
      vim \
      libnotify-bin \
      nano \
      wget \
      debconf-utils \
      apt-utils \
      language-pack-en-base


# set the locale
RUN export LC_ALL=en_US.UTF-8 && \
    export LANG=en_US.UTF-8

# set the timezone
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime



# install php
RUN apt-get install -y --force-yes php7.0-cli php7.0-dev php-pgsql \
    php-sqlite3 php-gd php-apcu php-curl php7.0-mcrypt php-imap \
    php-mysql php-memcached php7.0-readline php-xdebug php-mbstring \
    php-xml php7.0-zip php7.0-intl php7.0-bcmath php-soap php7.0-fpm
RUN sed -i -e "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.0/cli/php.ini && \
    sed -i -e "s/display_errors = .*/display_errors = On/" /etc/php/7.0/cli/php.ini && \
    sed -i -e "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.0/cli/php.ini
RUN sed -i -e "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.0/fpm/php.ini && \ 
    sed -i -e "s/display_errors = .*/display_errors = On/" /etc/php/7.0/fpm/php.ini && \ 
    sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.0/fpm/php.ini && \
    sed -i -e "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/7.0/fpm/php.ini && \
    sed -i -e "s/post_max_size = .*/post_max_size = 100M/" /etc/php/7.0/fpm/php.ini && \ 
    sed -i -e "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.0/fpm/php.ini
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.0/fpm/php-fpm.conf
RUN sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php/7.0/fpm/pool.d/www.conf && \
    sed -i -e "s/pm.max_children = 5/pm.max_children = 9/g" /etc/php/7.0/fpm/pool.d/www.conf && \
    sed -i -e "s/pm.start_servers = 2/pm.start_servers = 3/g" /etc/php/7.0/fpm/pool.d/www.conf && \
    sed -i -e "s/pm.min_spare_servers = 1/pm.min_spare_servers = 2/g" /etc/php/7.0/fpm/pool.d/www.conf && \
    sed -i -e "s/pm.max_spare_servers = 3/pm.max_spare_servers = 4/g" /etc/php/7.0/fpm/pool.d/www.conf && \
    sed -i -e "s/pm.max_requests = 500/pm.max_requests = 200/g" /etc/php/7.0/fpm/pool.d/www.conf && \
    sed -i -e "s/;listen.mode = 0660/listen.mode = 0750/g" /etc/php/7.0/fpm/pool.d/www.conf
RUN find /etc/php/7.0/cli/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;
RUN phpdismod -s cli xdebug
RUN phpenmod mcrypt && \
    mkdir -p /run/php/ && chown -Rf www-data.www-data /run/php



# install composer
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    printf "\nPATH=\"~/.composer/vendor/bin:\$PATH\"\n" | tee -a ~/.bashrc 

# install laravel envoy
RUN composer global require "laravel/envoy"

# install laravel installer
RUN composer global require "laravel/installer"

# install lumen installer
RUN composer global require "laravel/lumen-installer"

# install nodejs
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get install -y nodejs && \
    /usr/bin/npm install -g gulp && \
    /usr/bin/npm install -g bower

COPY container-content/init.sh  /
COPY container-content/entry.sh /

WORKDIR "/app"
CMD ["/entry.sh"]

