#!/bin/bash

source $HOME/stanford_travisci_scripts/bin/includes/script_functions.inc

# before_script
export PATH="$HOME/.composer/vendor/bin:$PATH"
export REPOSITORY_NAME=$(basename $TRAVIS_BUILD_DIR)

# download linky_clicky and copy over related tests and required files
if [ ! -z "$CLICKY_BRANCH" ]; then CLICKY_BRANCH="-b $CLICKY_BRANCH"; fi
echo "git clone --depth 1 $CLICKY_BRANCH https://github.com/SU-SWS/linky_clicky.git $HOME/linky_clicky"
git clone --depth 1 $CLICKY_BRANCH https://github.com/SU-SWS/linky_clicky.git $HOME/linky_clicky
mkdir -p $HOME/stanford_travisci_scripts/includes/config
mkdir $HOME/stanford_travisci_scripts/includes/extensions
cp $HOME/linky_clicky/includes/bootstrap/* $HOME/stanford_travisci_scripts/features/bootstrap/.
cp $HOME/linky_clicky/includes/config/default.yml $HOME/stanford_travisci_scripts/includes/config/.
cp $HOME/linky_clicky/includes/extensions/drupal.extension.yml $HOME/stanford_travisci_scripts/includes/extensions/.
cp $HOME/linky_clicky/includes/extensions/mink.extension.yml $HOME/stanford_travisci_scripts/includes/extensions/.

# determine which tests to copy based on type of repository or ONLY_TEST variable
if [ ! -z "$ONLY_TEST" ]; then
  copy_single_test
elif [ "$REPOSITORY_NAME" == "stanford-jumpstart-deployer" ]; then
  copy_product_tests
elif [ "$REPOSITORY_NAME" == "Stanford-Drupal-Profile" ]; then
  copy_uat_tests
else
  copy_module_tests
fi

# create directory for saving test failure screenshots and logs
mkdir $HOME/lakion
# Laikon's upload-screenshots module uses an obselete Imgur api
rm -rf $HOME/stanford_travisci_scripts/bin/upload-screenshots
cp $HOME/stanford_travisci_scripts/upload-screenshots.sh $HOME/stanford_travisci_scripts/bin/upload-screenshots
chmod +x $HOME/stanford_travisci_scripts/bin/upload-screenshots

# output which tests and assets have been copied over
echo "features ready for test run"
find $HOME/stanford_travisci_scripts/features/$REPOSITORY_NAME -type f -name "*.feature"
find $HOME/stanford_travisci_scripts/features -type f -name "*.png" -o -name "*.jpg"

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
