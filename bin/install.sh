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
  if [ ! -d $HOME/Stanford-Drupal-Profile ]; then git clone --depth 1 https://github.com/SU-SWS/Stanford-Drupal-Profile.git $HOME/Stanford-Drupal-Profile; fi
  grep -rl 'git@github.com:' $HOME/Stanford-Drupal-Profile | xargs sed -i 's|git@github.com:|https://github.com/|'
  drush make -y --force-complete $HOME/Stanford-Drupal-Profile/make/dept.make $TRAVIS_BUILD_DIR/html
  drush @local si -y stanford --db-url=mysql://root@localhost/drupal --account-name=admin --account-pass=admin
else
  if [ ! -d $HOME/stanford-jumpstart-deployer ]; then git clone --depth 1 -b proboci https://github.com/SU-SWS/stanford-jumpstart-deployer.git $HOME/stanford-jumpstart-deployer; fi
  grep -rl 'git@github.com:' $HOME/stanford-jumpstart-deployer | xargs sed -i 's|git@github.com:|https://github.com/|'
  drush make -y --force-complete $HOME/stanford-jumpstart-deployer/production/product/$PRODUCT_NAME/$PRODUCT_NAME.make $TRAVIS_BUILD_DIR/html
  export PROFILE_NAME=$(find $TRAVIS_BUILD_DIR/html/profiles -name "*jumpstart*" -type d -printf '%f\n')
  drush @local si -y $PROFILE_NAME --db-url=mysql://root@localhost/drupal --account-name=admin --account-pass=admin
fi

# disable webauth module and uncomment RewriteBase
drush @local dis -y webauth
sed -ie "s|# RewriteBase /|RewriteBase /|" $TRAVIS_BUILD_DIR/html/.htaccess
