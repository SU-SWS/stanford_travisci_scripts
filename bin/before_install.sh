#!/bin/bash

# before_install
cd stanford_travisci_scripts
composer self-update
composer install
composer global require drush/drush:7.1.0
phpenv rehash
cd ..
