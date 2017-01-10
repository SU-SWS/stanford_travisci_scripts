#!/bin/bash

# before_script
# download linky_clicky and copy over related tests
git clone https://github.com/SU-SWS/linky_clicky.git linky_clicky
cp linky_clicky/includes/features/SU-SWS/$TEST_FEATURE/$TEST_FEATURE features/.

cd html
drush runserver 127.0.0.1:8080 &
cd ..
until netstat -an 2>/dev/null | grep '8080.*LISTEN'; do sleep 0.2; done
wget http://selenium-release.storage.googleapis.com/2.40/selenium-server-standalone-2.40.0.jar
java -jar selenium-server-standalone-2.40.0.jar -p 4444 &

# give the webserver time to start up before running tests
sleep 5

# start xvfb virtual display
export DISPLAY=:99.0
sh -e /etc/init.d/xvfb start

# give xvfb time to launch before running tests
sleep 3
