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
cp $HOME/stanford_travisci_scripts/mink.extension.yml $HOME/stanford_travisci_scripts/includes/extensions/.

# determine which tests to copy based on type of repository or ONLY_TEST variable
copy_assets
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
ls $HOME/stanford_travisci_scripts/img

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

# start php runserver silently and with custom router
# custom router is required for runserver to process addresses with '.'
# must be started in the site's root directory
cp $HOME/stanford_travisci_scripts/routing.php $HOME/html/routing.php
cd $HOME/html
php -S 127.0.0.1:8080 $HOME/html/routing.php &>/dev/null &
# wait until server is up and running before proceeding
until netstat -an 2>/dev/null | grep '8080.*LISTEN'; do true; done
cd ..

# download and install Chrome
sudo apt-get install libxss1 libappindicator1 libindicator7 vim wget -y
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

# Unpackaging chrome returns an error because it is missing dependencies, which is not a problem,
# We install them a moment later.  So adding || true to be sure this behavior does not quit the script.
sudo dpkg -i google-chrome-stable_current_amd64.deb || true
sudo apt-get -f install -y
google-chrome --version

status "Installing Chromedriver"
wget https://chromedriver.storage.googleapis.com/2.35/chromedriver_linux64.zip
unzip chromedriver_linux64.zip
sudo mv -f chromedriver /usr/local/share/chromedriver
sudo ln -s /usr/local/share/chromedriver /usr/local/bin/chromedriver
sudo ln -s /usr/local/share/chromedriver /usr/bin/chromedriver

# download recommended version of selenium-server, start, silence, and background process
wget http://selenium-release.storage.googleapis.com/2.47/selenium-server-standalone-2.47.1.jar
java -jar selenium-server-standalone-2.47.1.jar -p 4444 &>/dev/null &

# wait until selenium-server is up and running before proceeding
until netstat -an 2>/dev/null | grep '4444.*LISTEN'; do true; done
