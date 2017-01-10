#!/bin/bash

# install
# remove preexisting site build
rm html
git clone -b travis https://github.com/SU-SWS/Stanford-Drupal-Profile.git Stanford-Drupal-Profile

# download site files in travis build directory
drush make -y --force-complete Stanford-Drupal-Profile/make/dept.make html
mv stanford_travisci_scripts/.htaccess html/.

# pass in absolute path of travis build directory for drupal root
mkdir ~/.drush
sed -e "s|TEST_FEATURE|${TRAVIS_BUILD_DIR}|" stanford_travisci_scripts/aliases.drushrc.php > ~/.drush/aliases.drushrc.php

# install site with stanford self-service profile
drush @local si -y stanford --db-url=mysql://root@localhost/drupal --account-name=admin --account-pass=admin

# disable webauth module, start webserver, and start selenium webdriver
drush @local dis -y webauth
drush @local runserver 127.0.0.1:8080 &
until netstat -an 2>/dev/null | grep '8080.*LISTEN'; do sleep 0.2; done
wget http://selenium-release.storage.googleapis.com/2.40/selenium-server-standalone-2.40.0.jar
java -jar selenium-server-standalone-2.40.0.jar -p 4444 &
# give the webserver time to start up before running tests
sleep 5
