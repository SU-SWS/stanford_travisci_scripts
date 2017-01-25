#!/bin/bash

# before_install
cd $HOME/stanford_travisci_scripts
composer install
composer global require drush/drush:7.1.0
phpenv config-rm xdebug.ini
phpenv rehash
cd $TRAVIS_BUILD_DIR
