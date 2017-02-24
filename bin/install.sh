#!/bin/bash

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
    git clone https://github.com/SU-SWS/$MODULE_NAME.git $HOME/html/sites/all/modules/stanford/$MODULE_NAME
  fi
done

# Enable modules and submodules if specified.
drush @local en -y $REPOSITORY_NAME
if [ ! -z "$ENABLE_MODULES" ]; then
  drush @local en -y $ENABLE_MODULES
fi

# Ensure that all features are in the state that they should be.
drush @local en -y "features"
drush @local fra -y
