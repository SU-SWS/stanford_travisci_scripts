#!/bin/bash

# before_install
composer self-update
export BASEDIR=${PWD}
phpenv rehash
composer install

# before_script
rm -rf html
git clone -b travis https://github.com/SU-SWS/Stanford-Drupal-Profile.git $BASEDIR/Stanford-Drupal-Profile
$BASEDIR/vendor/bin/drush make -y --force-complete $BASEDIR/Stanford-Drupal-Profile/make/dept.make html
cd html
$BASEDIR/vendor/bin/drush si -y stanford --db-url=mysql://root@localhost/drupal --account-name=admin --account-pass=admin
git clone https://github.com/SU-SWS/linky_clicky.git $BASEDIR/linky_clicky
mkdir features
cp $BASEDIR/linky_clicky/sites/uat/features/stanford_bean_types.feature features/.
