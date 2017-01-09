#!/bin/bash

# before_script
# find the name of the module being tested
cd ../
TEST_FEATURE=$(ls *.info | cut -f1 -d".")
# download linky_clicky and copy over related tests
git clone https://github.com/SU-SWS/linky_clicky.git $BASEDIR/linky_clicky
# remove previously tested features
rm $BASEDIR/features/*.feature
cp $BASEDIR/linky_clicky/includes/features/SU-SWS/$TEST_FEATURE/$TEST_FEATURE.feature $BASEDIR/features/.
# start xvfb virtual display
export DISPLAY=:99.0
sh -e /etc/init.d/xvfb start
# give xvfb time to launch before running tests
sleep 3
