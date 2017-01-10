#!/bin/bash

# before_install
composer install
composer global require drush/drush:7.1.0
export PATH="$HOME/.composer/vendor/bin:$PATH"
phpenv rehash
cd ..
