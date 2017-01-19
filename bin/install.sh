#!/bin/bash

# install
export PATH="$HOME/.composer/vendor/bin:$PATH"
git clone --depth 1 -b travis https://github.com/SU-SWS/Stanford-Drupal-Profile.git

# download site files in travis build directory
drush make -y --force-complete Stanford-Drupal-Profile/make/dept.make html

# pass in absolute path of travis build directory for drupal root
sed -e "s|BUILD_DIR|${TRAVIS_BUILD_DIR}|" stanford_travisci_scripts/aliases.drushrc.php > ~/.drush/aliases.drushrc.php
# install site with stanford self-service profile
drush @local si -y stanford --db-url=mysql://root@localhost/drupal --account-name=admin --account-pass=admin
sed -ie "s|# RewriteBase /|RewriteBase /|" html/.htaccess

# disable webauth module and uncomment RewriteBase
drush @local dis -y webauth

