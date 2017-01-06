#!/bin/bash

# install
rm -rf html
git clone -b travis https://github.com/SU-SWS/Stanford-Drupal-Profile.git Stanford-Drupal-Profile
$BASEDIR/vendor/bin/drush make -y --force-complete Stanford-Drupal-Profile/make/dept.make html
cd html
$BASEDIR/vendor/bin/drush si -y stanford --db-url=mysql://root@localhost/drupal --account-name=admin --account-pass=admin
