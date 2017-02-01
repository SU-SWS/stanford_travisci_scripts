#!/bin/bash

# install
export PATH="$HOME/.composer/vendor/bin:$PATH"
sed "s|ACCESS_TOKEN|$ACCESS_TOKEN|" $HOME/stanford_travisci_scripts/.netrc > $HOME/.netrc

# save drush alias and update .htaccess file to allow rewriting
if [ ! -d $HOME/.drush ]; then mkdir $HOME/.drush; fi
cp $HOME/stanford_travisci_scripts/aliases.drushrc.php $HOME/.drush/aliases.drushrc.php
sed -ie "s|TRAVIS_BUILD_DIR|$TRAVIS_BUILD_DIR|" $HOME/.drush/aliases.drushrc.php
cat $HOME/.drush/aliases.drushrc.php

if [ -z "$PRODUCT_NAME" ]; then
  git clone --depth 1 -b travis https://github.com/SU-SWS/Stanford-Drupal-Profile.git $HOME/Stanford-Drupal-Profile
  drush make -y --force-complete $HOME/Stanford-Drupal-Profile/make/dept.make html
  drush @local si -y stanford --db-url=mysql://root@localhost/drupal --account-name=admin --account-pass=admin
else
  git clone --depth 1 -b proboci https://github.com/SU-SWS/stanford-jumpstart-deployer.git $HOME/stanford-jumpstart-deployer
  drush make -y --force-complete $HOME/stanford-jumpstart-deployer/production/product/$PRODUCT_NAME/$PRODUCT_NAME.make html
  PROFILE_NAME=$(find $TRAVIS_BUILD_DIR/html/profiles -name "*jumpstart*" -type d -printf '%f\n')
  drush @local si -y $PROFILE_NAME --db-url=mysql://root@localhost/drupal --account-name=admin --account-pass=admin
fi

# disable webauth module and uncomment RewriteBase
drush @local dis -y webauth
sed -ie "s|# RewriteBase /|RewriteBase /|" html/.htaccess
