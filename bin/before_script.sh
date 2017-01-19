#!/bin/bash

# before_script
export PATH="$HOME/.composer/vendor/bin:$PATH"
# download linky_clicky and copy over related tests and required files
git clone --depth 1 https://github.com/SU-SWS/linky_clicky.git
mkdir -p stanford_travisci_scripts/includes/config
mkdir stanford_travisci_scripts/includes/extensions
cp -r linky_clicky/includes/features/SU-SWS/$TEST_FEATURE stanford_travisci_scripts/features/.
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

# kill persistent proccesses from previous builds
# kill processes on port used by selenium-server
kill $(lsof -ti tcp:4444)
# kill processes on port used by php runserver
kill $(lsof -t -i:8080)

# start php runserver from within site directory
# alias failed to find webroot
cd html
drush runserver 127.0.0.1:8080 &
# wait until server is up and running before proceeding
until netstat -an 2>/dev/null | grep '8080.*LISTEN'; do true; done
cd ..

# download recommended version of selenium-server, start and background process
wget http://selenium-release.storage.googleapis.com/2.47/selenium-server-standalone-2.47.1.jar
java -jar selenium-server-standalone-2.47.1.jar -p 4444 &>/dev/null &

# wait until selenium-server is up and running before proceeding
until netstat -an 2>/dev/null | grep '4444.*LISTEN'; do true; done
