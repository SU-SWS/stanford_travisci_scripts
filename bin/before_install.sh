#!/bin/bash

# before_install
mkdir ~/.drush
sed -e "s|TEST_FEATURE|${TRAVIS_BUILD_DIR}|" stanford_travisci_scripts/aliases.drushrc.php > ~/.drush/aliases.drushrc.php
cat ~/.drush/aliases.drushrc.php
composer self-update
composer install
composer global require drush/drush:7.1.0
phpenv rehash
