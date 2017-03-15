#!/bin/bash

# functions used by install.sh to determine which make files should be used to build a site
function install_from_deployer {
  # clone deployer and echo which branch will be cloned and used for the site build
  if [ ! -z "$DEPLOYER_BRANCH" ]; then DEPLOYER_BRANCH="-b $DEPLOYER_BRANCH"; fi
  echo "git clone --depth 1 $DEPLOYER_BRANCH https://github.com/SU-SWS/stanford-jumpstart-deployer.git $HOME/stanford-jumpstart-deployer"
  git clone --depth 1 $DEPLOYER_BRANCH https://github.com/SU-SWS/stanford-jumpstart-deployer.git $HOME/stanford-jumpstart-deployer

  # change git clones to https so they can be downloaded with access tokens
  grep -rl 'git@github.com:' $HOME/stanford-jumpstart-deployer | xargs sed -i 's|git@github.com:|https://github.com/|'

  # build site based on specified product name
  if [ -z "$PRODUCT_VERSION" ]; then PRODUCT_VERSION="production"; fi
  drush make -y --force-complete $HOME/stanford-jumpstart-deployer/$PRODUCT_VERSION/product/$PRODUCT_NAME/$PRODUCT_NAME.make $HOME/html

  # find profile name by looking for "jumpstart" in profiles directory
  export PROFILE_NAME=$(find $HOME/html/profiles -name "*jumpstart*" -type d -printf '%f\n')

  # install site with product profile
  drush @local si -y $PROFILE_NAME --db-url=mysql://root@localhost/drupal --account-name=admin --account-pass=admin
}

function install_from_drupal_profile {
  # clone Drupal-Profile and echo which branch will be cloned and used for the site build
  if [ ! -z "$DRUPAL_PROFILE_BRANCH" ]; then DRUPAL_PROFILE_BRANCH="-b $DRUPAL_PROFILE_BRANCH"; fi
  echo "git clone --depth 1 $DRUPAL_PROFILE_BRANCH https://github.com/SU-SWS/Stanford-Drupal-Profile.git $HOME/Stanford-Drupal-Profile"
  git clone --depth 1 $DRUPAL_PROFILE_BRANCH https://github.com/SU-SWS/Stanford-Drupal-Profile.git $HOME/Stanford-Drupal-Profile

  # change git clones to https so they can be downloaded with access tokens
  grep -rl 'git@github.com:' $HOME/Stanford-Drupal-Profile | xargs sed -i 's|git@github.com:|https://github.com/|'

  # build self-service site
  drush make -y --force-complete $HOME/Stanford-Drupal-Profile/make/dept.make $HOME/html

  # install site with stanford, ie. self-service, profile
  drush @local si -y stanford --db-url=mysql://root@localhost/drupal --account-name=admin --account-pass=admin
}

function update_test_branch {
  # download pull request origination branch when testing profiles
  if [ "$REPOSITORY_NAME" == "Stanford-Drupal-Profile" ] && [ -z "$DRUPAL_PROFILE_BRANCH" ]; then
    DRUPAL_PROFILE_BRANCH="$TRAVIS_PULL_REQUEST_BRANCH"
  elif [ "$REPOSITORY_NAME" == "stanford-jumpstart-deployer" ] && [ -z "$DEPLOYER_BRANCH" ]; then
    DEPLOYER_BRANCH="$TRAVIS_PULL_REQUEST_BRANCH"
  fi
}

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
  # module directory should not be there if updating the module version
  if [[ "$MODULE_NAME" == "stanford"* ]] && [ ! -d $HOME/html/sites/all/modules/stanford/$MODULE_NAME ]; then
    download_stanford_module
  else
    drush @local dl -y $MODULE
  fi
  drush @local en -y $MODULE_NAME
}

