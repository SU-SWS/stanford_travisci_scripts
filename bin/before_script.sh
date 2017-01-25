#!/bin/bash

# before_script
export PATH="$HOME/.composer/vendor/bin:$PATH"
# download linky_clicky and copy over related tests and required files
git clone --depth 1 https://github.com/SU-SWS/linky_clicky.git
mkdir -p stanford_travisci_scripts/includes/config
mkdir stanford_travisci_scripts/includes/extensions

# copy over feature tests unless profile testing, in which case, copy over uat tests
if [[ $REPOSITORY_NAME == "Stanford-Drupal-Profile" ]] || [[ $REPOSITORY_NAME == "stanford-jumpstart-deployer"]];then
  cp -r linky_clicky/sites/uat/features stanford_travisci_scripts/features/$RESPOSITORY_NAME
else
  cp -r linky_clicky/includes/features/SU-SWS/$REPOSITORY_NAME stanford_travisci_scripts/features/.
fi
cp linky_clicky/includes/bootstrap/* stanford_travisci_scripts/features/bootstrap/.
cp linky_clicky/includes/config/default.yml stanford_travisci_scripts/includes/config/.
cp linky_clicky/includes/extensions/drupal.extension.yml stanford_travisci_scripts/includes/extensions/.
cp linky_clicky/includes/extensions/mink.extension.yml stanford_travisci_scripts/includes/extensions/.

# start xvfb virtual display
export DISPLAY=:99.0
sh -e /etc/init.d/xvfb start

# give xvfb time to launch before proceeding
sleep 3

# install net-tools
sudo apt-get install -y net-tools

# start php runserver silently and from within site directory
# alias failed to find webroot
cd html
drush runserver 127.0.0.1:8080 &>/dev/null &
# wait until server is up and running before proceeding
until netstat -an 2>/dev/null | grep '8080.*LISTEN'; do true; done
cd ..

# download recommended version of selenium-server, start, silence, and background process
wget http://selenium-release.storage.googleapis.com/2.47/selenium-server-standalone-2.47.1.jar
java -jar selenium-server-standalone-2.47.1.jar -p 4444 &>/dev/null &

# wait until selenium-server is up and running before proceeding
until netstat -an 2>/dev/null | grep '4444.*LISTEN'; do true; done
