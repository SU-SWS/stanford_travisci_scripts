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

# Adjust the rewrite base for the local host and enable clean url's.
sed -ie "s|# RewriteBase /|RewriteBase /|" $HOME/html/.htaccess
drush @local vset clean_url 1

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

# Determine if a new module needs to be downloaded
function remove_old_module_version {
  if [[ "$CURRENT_MODULE_VERSION" != "$MODULE_BRANCH" ]] && [ ! -z "$CURRENT_MODULE_VERSION" ]; then
    rm -rf $CURRENT_MODULE_PATH
  fi
}

function find_old_module_version {
  CURRENT_MODULE_PATH=$(find $HOME/html/sites/all/modules -type d -name "$MODULE_NAME")
  if [ ! -z "$CURRENT_MODULE_PATH" ]; then
    CURRENT_MODULE_VERSION=$(drush @local pmi --format=list --fields=version --field-labels=0 $MODULE_NAME)
    echo "module version: $CURRENT_MODULE_VERSION"
    remove_old_module_version
  fi
}

# Find modules with specified versions
function check_for_module_version {
  if [[ "$MODULE" == *"-"* ]]; then
    MODULE_NAME=$(echo $MODULE | cut -d "-" -f 1)
    MODULE_BRANCH=$(echo $MODULE | cut -d "-" -f 2-)
    echo "module name: $MODULE_NAME module branch: $MODULE_BRANCH"
    find_old_module_version
  else
    MODULE_NAME=$MODULE
    MODULE_BRANCH=""
  fi
}

function download_stanford_module {
  EXISTS=$(curl -X HEAD -I https://github.com/SU-SWS/$MODULE_NAME 2>/dev/null | head -n 1);
  if [[ $EXISTS =~ .*200\ OK.* ]]; then
    if [ ! -z "$MODULE_BRANCH" ] && [ -z "$MODULE_PATH" ]; then MODULE_BRANCH="-b $MODULE_BRANCH"; fi
    echo "git clone $MODULE_BRANCH https://github.com/SU-SWS/$MODULE_NAME.git $HOME/html/sites/all/modules/stanford/$MODULE_NAME"
    git clone $MODULE_BRANCH https://github.com/SU-SWS/$MODULE_NAME.git $HOME/html/sites/all/modules/stanford/$MODULE_NAME
  fi
}

function install_new_module_version {
  if [[ "$MODULE_NAME" == "stanford"* ]]; then
    download_stanford_module
  else
    drush @local dl -y $MODULE
  fi
  drush @local en -y $MODULE_NAME
}

if [ ! -z "$ENABLE_MODULES" ]; then
  for MODULE in $ENABLE_MODULES; do
    echo $MODULE
    check_for_module_version
    install_new_module_version
  done
fi

# Enable modules and submodules if specified.
if [[ ! "$REPOSITORY_NAME" =~ "Stanford-Drupal-Profile"|"stanford-jumpstart-deployer" ]]; then
  drush @local en -y $REPOSITORY_NAME
fi

# Ensure that all features are in the state that they should be.
drush @local en -y "features"
drush @local fra -y
