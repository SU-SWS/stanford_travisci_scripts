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
  drush make -y --force-complete $HOME/stanford-jumpstart-deployer/production/product/$PRODUCT_NAME/$PRODUCT_NAME.make $HOME/html

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
  if [ "$REPOSITORY_NAME" == "Stanford-Drupal-Profile" ]; then
    DRUPAL_PROFILE_BRANCH="$TRAVIS_PULL_REQUEST_BRANCH"
  elif [ "$REPOSITORY_NAME" == "stanford-jumpstart-deployer" ]; then
    DEPLOYER_BRANCH="$TRAVIS_PULL_REQUEST_BRANCH"
  fi
}
