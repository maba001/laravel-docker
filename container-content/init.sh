#!/bin/bash

cd /app
composer install

npm install || npm install --no-optional

