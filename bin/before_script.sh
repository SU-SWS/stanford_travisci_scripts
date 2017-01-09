#!/bin/bash

# before_script
# find the name of the module being tested
TEST_FEATURE=$(ls *.info | cut -f1 -d".")
# download linky_clicky and copy over related tests
git clone https://github.com/SU-SWS/linky_clicky.git linky_clicky
# remove previously tested features
rm features
mv stanford_travisci_scripts/features .
cp linky_clicky/includes/features/SU-SWS/$TEST_FEATURE/$TEST_FEATURE.feature features/.
# start xvfb virtual display
export DISPLAY=:99.0
sh -e /etc/init.d/xvfb start
# give xvfb time to launch before running tests
sleep 3
