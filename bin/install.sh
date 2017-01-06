#!/bin/bash

# install
export PATH="$HOME/.composer/vendor/bin:$PATH"i
rm -rf ~/html
git clone -b travis https://github.com/SU-SWS/Stanford-Drupal-Profile.git $BASEDIR/Stanford-Drupal-Profile
drush make -y --force-complete Stanford-Drupal-Profile/make/dept.make ~/html
cd ~/html
cp $BASEDIR/.htaccess .
cp $BASEDIR/aliases.drushrc.php ~/.drush
drush @local si -y stanford --db-url=mysql://root@localhost/drupal --account-name=admin --account-pass=admin
drush @local dis -y webauth
drush @local runserver 127.0.0.1:8080 &
until netstat -an 2>/dev/null | grep '8080.*LISTEN'; do sleep 0.2; done
wget http://selenium-release.storage.googleapis.com/2.40/selenium-server-standalone-2.40.0.jar
java -jar selenium-server-standalone-2.40.0.jar -p 4444 &
sleep 5
