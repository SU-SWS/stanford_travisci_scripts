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
git clone --depth 1 https://github.com/SU-SWS/j8 $HOME/j8
cd $HOME/j8
composer install --prefer-source
ln -s $HOME/j8/web $HOME/html

# install site
bin/drupal site:install stanford_sites_jumpstart --force --no-interaction --langcode="en" --db-type="mysql" --db-host="127.0.0.1" --db-name="drupal8" --db-user="root" --db-pass="" --db-port="3306" --site-name="J8" --site-mail="admin@example.com" --account-name="admin" --account-mail="admin@example.com" --account-pass="admin"

# Place the base path in the settings.php file because it has a non default port.
chmod 0777 $HOME/html/sites/default/settings.php
sudo echo "\$base_url = \"http://127.0.0.1:8888\";" >> $HOME/html/sites/default/settings.php
chmod 0644 $HOME/html/sites/default/settings.php

# Adjust the rewrite base for the local host and enable clean url's.
sed -ie "s|# RewriteBase /|RewriteBase /|" $HOME/html/.htaccess
drush @local vset clean_url 1

# Move latest module version into sites/all/stanford
# Ensure that files is writable.
chmod 0777 $HOME/html/sites/default/files

# start php runserver silently and with custom router
# must be started in the site's root directory
cp $HOME/stanford_travisci_scripts/routing.php $HOME/html/routing.php
cd $HOME/html
php -S 127.0.0.1:8888 $HOME/html/routing.php &>/dev/null &
# wait until server is up and running before proceeding
until netstat -an 2>/dev/null | grep '8080.*LISTEN'; do true; done
cd ..

if (`curl --silent http://127.0.0.1:8888 | grep "block-stanford-basic-branding"`); then
  exit 0
else
  exit 1
fi
