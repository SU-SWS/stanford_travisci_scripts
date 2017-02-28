#!/bin/bash

source $HOME/stanford_travisci_scripts/bin/includes/install_functions.inc

# install
export PATH="$HOME/.composer/vendor/bin:$PATH"
export REPOSITORY_NAME=$(basename $TRAVIS_BUILD_DIR)

# save GitHub access token so we can clone from private repositories
sed "s|ACCESS_TOKEN|$ACCESS_TOKEN|" $HOME/stanford_travisci_scripts/.netrc > $HOME/.netrc

# save drush alias and update .htaccess file to allow rewriting
if [ ! -d $HOME/.drush ]; then mkdir $HOME/.drush; fi
cp $HOME/stanford_travisci_scripts/aliases.drushrc.php $HOME/.drush/aliases.drushrc.php
sed -ie "s|HOME|$HOME|" $HOME/.drush/aliases.drushrc.php
cat $HOME/.drush/aliases.drushrc.php

update_test_branch
if [ -z "$PRODUCT_NAME" ]; then
  install_from_drupal_profile
else
  install_from_deployer
fi

# Adjust the rewrite base for the local host.
sed -ie "s|# RewriteBase /|RewriteBase /|" $HOME/html/.htaccess

# Move latest module version into sites/all/stanford
rm -rf $HOME/html/sites/all/modules/stanford/$REPOSITORY_NAME
mv $TRAVIS_BUILD_DIR $HOME/html/sites/all/modules/stanford/$REPOSITORY_NAME
drush @local updb -y

# Place the base path in the settings.php file because it has a non default port.
chmod 0777 $HOME/html/sites/default/settings.php
sudo echo "\$base_url = \"http://127.0.0.1:8080\";" >> $HOME/html/sites/default/settings.php
chmod 0644 $HOME/html/sites/default/settings.php

# Ensure that files is writable.
chmod 0777 $HOME/html/sites/default/files

# Disable modules based on testing requirements.
if [ ! -z "$DISABLE_MODULES" ]; then
  drush @local dis -y "$DISABLE_MODULES"
fi

# Download stanford modules if not already present in sites/all/stanford.
for MODULE_NAME in $ENABLE_MODULES; do
  if [[ "$MODULE_NAME" == "stanford"* ]] && [ ! -d $HOME/html/sites/all/modules/stanford/$MODULE_NAME ]; then
    EXISTS=$(curl -X HEAD -I https://github.com/SU-SWS/$MODULE_NAME 2>/dev/null | head -n 1);
    if [[ $EXISTS =~ .*200\ OK.* ]]; then
      git clone https://github.com/SU-SWS/$MODULE_NAME.git $HOME/html/sites/all/modules/stanford/$MODULE_NAME
    fi
  fi
done

# Enable modules and submodules if specified.
if [[ ! "$REPOSITORY_NAME" =~ "Stanford-Drupal-Profile"|"stanford-jumpstart-deployer" ]]; then
  drush @local en -y $REPOSITORY_NAME
fi
if [ ! -z "$ENABLE_MODULES" ]; then
  drush @local en -y $ENABLE_MODULES
fi

# Ensure that all features are in the state that they should be.
drush @local en -y "features"
drush @local fra -y
