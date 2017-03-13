#!/bin/bash

# before_install
cd $HOME/stanford_travisci_scripts
composer install
composer global require drush/drush:8.1.10
phpenv config-rm xdebug.ini
phpenv rehash
cd $HOME
