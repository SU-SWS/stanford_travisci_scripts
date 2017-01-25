#!/bin/bash

# install
export PATH="$HOME/.composer/vendor/bin:$PATH"
sed "s|ACCESS_TOKEN|$ACCESS_TOKEN|" stanford_travisci_scripts/.netrc > $HOME/.netrc

# save drush alias and update .htaccess file to allow rewriting
if [ ! -d $HOME/.drush ]; then mkdir $HOME/.drush; fi
cp stanford_travisci_scripts/aliases.drushrc.php $HOME/.drush/aliases.drushrc.php
sed -ie "s|TRAVIS_BUILD_DIR|$TRAVIS_BUILD_DIR|" $HOME/.drush/aliases.drushrc.php
cat $HOME/.drush/aliases.drushrc.php

if [ "$REPOSITORY_NAME" = "stanford-jumpstart-deployer" ]; then
  drush make -y --force-complete production/product/jumpstart-academic/jumpstart-academic.make html
  drush @local si -y stanford_sites_jumpstart_academic --db-url=mysql://root@localhost/drupal --account-name=admin --account-pass=admin
else
  git clone --depth 1 -b travis https://github.com/SU-SWS/Stanford-Drupal-Profile.git
  drush make -y --force-complete Stanford-Drupal-Profile/make/dept.make html
  drush @local si -y stanford --db-url=mysql://root@localhost/drupal --account-name=admin --account-pass=admin
fi

# disable webauth module and uncomment RewriteBase
drush @local dis -y webauth
sed -ie "s|# RewriteBase /|RewriteBase /|" html/.htaccess
