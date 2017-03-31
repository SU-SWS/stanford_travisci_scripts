#!/bin/bash

# before_script
export PATH="$HOME/.composer/vendor/bin:$PATH"
export REPOSITORY_NAME=$(basename $TRAVIS_BUILD_DIR)

# install net-tools
sudo apt-get install -y net-tools

# kill any processes on ports from previously canceled builds
kill $(lsof -ti tcp:4444)
kill $(lsof -t -i:8080)

# start php runserver silently and with custom router
# must be started in the site's root directory
cp $HOME/stanford_travisci_scripts/routing.php $HOME/html/routing.php
cd $HOME/html
php -S 127.0.0.1:8080 $HOME/html/routing.php &>/dev/null &
# wait until server is up and running before proceeding
until netstat -an 2>/dev/null | grep '8080.*LISTEN'; do true; done
cd ..

if (`curl --silent http://127.0.0.1:8080 | grep "block-stanford-basic-branding"`); then
  echo "You appear to have built a Drupal 8 site"
  exit 0
else
  exit 1
fi
