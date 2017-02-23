#!/bin/bash

# before_install
export REPOSITORY_NAME=$(basename $TRAVIS_BUILD_DIR)⏎
echo "$REPOSITORY_NAME"
cd $HOME/stanford_travisci_scripts
composer install
composer global require drush/drush:7.1.0
phpenv config-rm xdebug.ini
phpenv rehash
cd $HOME
