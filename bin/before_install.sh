#!/bin/bash

# before_install
composer self-update
composer install
composer global require drush/drush:7.1.0
composer global require behat/behat:~3.1.0
phpenv rehash
