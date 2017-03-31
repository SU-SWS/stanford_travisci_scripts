#!/bin/bash

# install
export PATH="$HOME/.composer/vendor/bin:$PATH"
export REPOSITORY_NAME=$(basename $TRAVIS_BUILD_DIR)

# save GitHub access token so we can clone from private repositories
composer config --global github-oauth.github.com $ACCESS_TOKEN

# save drush alias
if [ ! -d $HOME/.drush ]; then mkdir $HOME/.drush; fi
cp $HOME/stanford_travisci_scripts/aliases.drushrc.php $HOME/.drush/aliases.drushrc.php
sed -ie "s|HOME|$HOME|" $HOME/.drush/aliases.drushrc.php
cat $HOME/.drush/aliases.drushrc.php

# install d8 site
git clone --depth 1 https://github.com/SU-SWS/j8 $HOME/html
cd j8/
composer install --prefer-source
ln -s $HOME/j8/web $HOME/html

# Place the base path in the settings.php file because it has a non default port.
chmod 0777 $HOME/html/sites/default/settings.php
sudo echo "\$base_url = \"http://127.0.0.1:8080\";" >> $HOME/html/sites/default/settings.php
sudo echo d8_settings.php >> $HOME/html/web/sites/default/settings.php
chmod 0644 $HOME/html/sites/default/settings.php

# install site
bin/drupal site:install stanford_sites_jumpstart --force

# Adjust the rewrite base for the local host and enable clean url's.
sed -ie "s|# RewriteBase /|RewriteBase /|" $HOME/html/.htaccess
drush @local vset clean_url 1

# Move latest module version into sites/all/stanford
# Ensure that files is writable.
chmod 0777 $HOME/html/sites/default/files

# Disable modules based on testing requirements.
if [ ! -z "$DISABLE_MODULES" ]; then
  drush @local dis -y "$DISABLE_MODULES"
fi


