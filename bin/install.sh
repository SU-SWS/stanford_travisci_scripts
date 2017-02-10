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
  if [ ! -z "$DRUPAL_PROFILE_BRANCH" ]; then DRUPAL_PROFILE_BRANCH="-b $DRUPAL_PROFILE_BRANCH"; fi
  git clone --depth 1 $DRUPAL_PROFILE_BRANCH https://github.com/SU-SWS/Stanford-Drupal-Profile.git $HOME/Stanford-Drupal-Profile
  grep -rl 'git@github.com:' $HOME/Stanford-Drupal-Profile | xargs sed -i 's|git@github.com:|https://github.com/|'
  drush make -y --force-complete $HOME/Stanford-Drupal-Profile/make/dept.make $TRAVIS_BUILD_DIR/html
  drush @local si -y stanford --db-url=mysql://root@localhost/drupal --account-name=admin --account-pass=admin
else
  if [ ! -z "$DEPLOYER_BRANCH" ]; then DEPLOYER_BRANCH="-b $DEPLOYER_BRANCH"; fi
  git clone --depth 1 $DEPLOYER_BRANCH https://github.com/SU-SWS/stanford-jumpstart-deployer.git $HOME/stanford-jumpstart-deployer
  grep -rl 'git@github.com:' $HOME/stanford-jumpstart-deployer | xargs sed -i 's|git@github.com:|https://github.com/|'
  drush make -y --force-complete $HOME/stanford-jumpstart-deployer/production/product/$PRODUCT_NAME/$PRODUCT_NAME.make $TRAVIS_BUILD_DIR/html
  export PROFILE_NAME=$(find $TRAVIS_BUILD_DIR/html/profiles -name "*jumpstart*" -type d -printf '%f\n')
  drush @local si -y $PROFILE_NAME --db-url=mysql://root@localhost/drupal --account-name=admin --account-pass=admin
fi
sed -ie "s|# RewriteBase /|RewriteBase /|" $TRAVIS_BUILD_DIR/html/.htaccess
chmod 0777 $TRAVIS_BUILD_DIR/html/sites/default/settings.php
sudo echo "\$base_url = \"http://127.0.0.1:8080\";" >> $TRAVIS_BUILD_DIR/html/sites/default/settings.php
chmod 0644 $TRAVIS_BUILD_DIR/html/sites/default/settings.php

# Disable modules based on testing requirements.
if [ ! -z "$DISABLE_MODULES" ]; then
  drush @local dis -y "$DISABLE_MODULES"
fi

# Download stanford modules if not already present in sites/all/stanford.
for MODULE_NAME in $ENABLE_MODULES; do
  if [[ "$MODULE_NAME" == "stanford"* ]] && [ ! -d $TRAVIS_BUILD_DIR/html/sites/all/modules/stanford/$MODULE_NAME ]; then
    git clone https://github.com/SU-SWS/$MODULE_NAME.git $TRAVIS_BUILD_DIR/html/sites/all/modules/stanford/$MODULE_NAME
  fi
done

# Enable modules and submodules if specified.
if [ ! -z "$ENABLE_MODULES" ]; then
  drush @local en -y $ENABLE_MODULES
fi

# Ensure that all features are in the state that they should be.
drush @local en -y "features"
drush @local fra -y
