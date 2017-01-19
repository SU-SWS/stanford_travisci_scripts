#!/bin/bash

# before_install
netstat -an 2>/dev/null | grep '8080.*LISTEN'
netstat -an 2>/dev/null | grep '4444.*LISTEN'

cd stanford_travisci_scripts
composer install
composer global require drush/drush:7.1.0
phpenv rehash
cd ..
