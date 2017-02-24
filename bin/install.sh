#!/bin/bash

# install
export PATH="$HOME/.composer/vendor/bin:$PATH"
export REPOSITORY_NAME=$(find $TRAVIS_BUILD_URL -mindepth 1 -maxdepth 1 -name "*.info" -type f -printf '%f\n' | cut -f1 -d".")
if [ -z "$REPOSITORY_NAME"]; then
  REPOSITORY_NAME="stanford-jumpstart-deployer"
fi
sed "s|ACCESS_TOKEN|$ACCESS_TOKEN|" $HOME/stanford_travisci_scripts/.netrc > $HOME/.netrc

# save drush alias and update .htaccess file to allow rewriting
if [ ! -d $HOME/.drush ]; then mkdir $HOME/.drush; fi
cp $HOME/stanford_travisci_scripts/aliases.drushrc.php $HOME/.drush/aliases.drushrc.php
sed -ie "s|HOME|$HOME|" $HOME/.drush/aliases.drushrc.php
cat $HOME/.drush/aliases.drushrc.php

if [ -z "$PRODUCT_NAME" ]; then
  if [ ! -z "$DRUPAL_PROFILE_BRANCH" ]; then DRUPAL_PROFILE_BRANCH="-b $DRUPAL_PROFILE_BRANCH"; fi
  git clone --depth 1 $DRUPAL_PROFILE_BRANCH https://github.com/SU-SWS/Stanford-Drupal-Profile.git $HOME/Stanford-Drupal-Profile
  grep -rl 'git@github.com:' $HOME/Stanford-Drupal-Profile | xargs sed -i 's|git@github.com:|https://github.com/|'
  drush make -y --force-complete $HOME/Stanford-Drupal-Profile/make/dept.make $HOME/html
  drush @local si -y stanford --db-url=mysql://root@localhost/drupal --account-name=admin --account-pass=admin
else
  if [ ! -z "$DEPLOYER_BRANCH" ]; then DEPLOYER_BRANCH="-b $DEPLOYER_BRANCH"; fi
  git clone --depth 1 $DEPLOYER_BRANCH https://github.com/SU-SWS/stanford-jumpstart-deployer.git $HOME/stanford-jumpstart-deployer
  grep -rl 'git@github.com:' $HOME/stanford-jumpstart-deployer | xargs sed -i 's|git@github.com:|https://github.com/|'
  drush make -y --force-complete $HOME/stanford-jumpstart-deployer/production/product/$PRODUCT_NAME/$PRODUCT_NAME.make $HOME/html
  export PROFILE_NAME=$(find $HOME/html/profiles -name "*jumpstart*" -type d -printf '%f\n')
  drush @local si -y $PROFILE_NAME --db-url=mysql://root@localhost/drupal --account-name=admin --account-pass=admin
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
drush @local en -y $REPOSITORY_NAME
if [ ! -z "$ENABLE_MODULES" ]; then
  drush @local en -y $ENABLE_MODULES
fi

# Ensure that all features are in the state that they should be.
drush @local en -y "features"
drush @local fra -y
