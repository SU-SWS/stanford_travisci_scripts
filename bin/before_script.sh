#!/bin/bash

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

# copy over production product tests
function copy_product_tests {
  declare -A PRODUCTS_LIST=(
    ["jumpstart-academic"]="jsa"
    ["jumpstart-engineering"]="jse"
    ["jumpstart-plus"]="jsplus"
    ["jumpstart"]="jsv"
    ["jumpstart-lab"]="jsl"
  )
  ACRONYM="${PRODUCTS_LIST[$PRODUCT_NAME]}"
  echo "cp -r $HOME/linky_clicky/products/$ACRONYM/features $HOME/stanford_travisci_scripts/features/$REPOSITORY_NAME"
  cp -r $HOME/linky_clicky/products/$ACRONYM/features $HOME/stanford_travisci_scripts/features/$REPOSITORY_NAME
}

function copy_uat_tests {
  cp -r $HOME/linky_clicky/sites/uat/features $HOME/stanford_travisci_scripts/features/$REPOSITORY_NAME
}

function copy_module_tests {
  cp -r $HOME/linky_clicky/includes/features/SU-SWS/$REPOSITORY_NAME $HOME/stanford_travisci_scripts/features/.
}

# loop through and copy specific tests called for by ONLY_TEST variable
function copy_single_test {
  mkdir $HOME/stanford_travisci_scripts/features/$REPOSITORY_NAME
  TESTS=(`echo ${ONLY_TEST}`)
  for TEST in ${TESTS[@]}; do
    TEST_PATH=$(find $HOME/linky_clicky -type f -name "$TEST.feature")
    cp $TEST_PATH $HOME/stanford_travisci_scripts/features/$REPOSITORY_NAME/$TEST.feature
  done
}

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

# output which tests have been copied over
echo "features ready for test run"
echo $(find $HOME/stanford_travisci_scripts/features/$REPOSITORY_NAME -type f -name "*.feature")

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
