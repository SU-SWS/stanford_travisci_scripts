#!/bin/bash

# install
rm -rf $BASEDIR/html
git clone -b travis https://github.com/SU-SWS/Stanford-Drupal-Profile.git
$BASEDIR/vendor/bin/drush make -y --force-complete Stanford-Drupal-Profile/make/dept.make $BASEDIR/html
cd $BASEDIR/html
$BASEDIR/vendor/bin/drush si -y stanford --db-url=mysql://root@localhost/drupal --account-name=admin --account-pass=admin
