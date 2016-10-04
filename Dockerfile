FROM composer/composer:latest
MAINTAINER Alex

RUN composer global require "laravel/installer"

ENTRYPOINT bash

