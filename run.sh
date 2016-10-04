#!/bin/bash -xe

docker run -it --rm  \
           -v $(pwd)/app:/app  \
           scortum/laravel $@

