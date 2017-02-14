#!/bin/bash

# before_script
export PATH="$HOME/.composer/vendor/bin:$PATH"
export REPOSITORY_NAME=$(find $TRAVIS_BUILD_URL -mindepth 1 -maxdepth 1 -name "*.info" -type f -printf '%f\n' | cut -f1 -d".")
# download linky_clicky and copy over related tests and required files
if [ ! -z "$CLICKY_BRANCH" ]; then CLICKY_BRANCH="-b $CLICKY_BRANCH"; fi
git clone --depth 1 $CLICKY_BRANCH https://github.com/SU-SWS/linky_clicky.git $HOME/linky_clicky
mkdir -p $HOME/stanford_travisci_scripts/includes/config
mkdir $HOME/stanford_travisci_scripts/includes/extensions
ls $HOME/stanford_travisci_scripts/features

# copy over feature tests unless profile testing, in which case, copy over uat tests
cp -r $HOME/linky_clicky/includes/features/SU-SWS/$REPOSITORY_NAME $HOME/stanford_travisci_scripts/features/.
cp $HOME/linky_clicky/includes/bootstrap/* $HOME/stanford_travisci_scripts/features/bootstrap/.
cp $HOME/linky_clicky/includes/config/default.yml $HOME/stanford_travisci_scripts/includes/config/.
cp $HOME/linky_clicky/includes/extensions/drupal.extension.yml $HOME/stanford_travisci_scripts/includes/extensions/.
cp $HOME/linky_clicky/includes/extensions/mink.extension.yml $HOME/stanford_travisci_scripts/includes/extensions/.

# start xvfb virtual display
export DISPLAY=:99.0
sh -e /etc/init.d/xvfb start

# give xvfb time to launch before proceeding
sleep 3

# install net-tools
sudo apt-get install -y net-tools

# kill any processes on ports from previously canceled builds
kill $(lsof -ti tcp:4444)
kill $(lsof -t -i:8080)

# start php runserver silently and from within site directory
# alias failed to find webroot
cd $HOME/html
drush runserver 127.0.0.1:8080 &>/dev/null &
# wait until server is up and running before proceeding
until netstat -an 2>/dev/null | grep '8080.*LISTEN'; do true; done
cd ..

# download recommended version of selenium-server, start, silence, and background process
wget http://selenium-release.storage.googleapis.com/2.47/selenium-server-standalone-2.47.1.jar
java -jar selenium-server-standalone-2.47.1.jar -p 4444 &>/dev/null &

# wait until selenium-server is up and running before proceeding
until netstat -an 2>/dev/null | grep '4444.*LISTEN'; do true; done
