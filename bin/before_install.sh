#!/bin/bash

# before_install
composer self-update
composer install
export PATH="$HOME/.composer/vendor/bin:$PATH"
composer global require drush/drush:7.1.0
phpenv rehash
