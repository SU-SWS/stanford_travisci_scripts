#!/bin/bash

# before_script
cd ../
TEST_FEATURE=$(ls *.info | cut -f1 -d".")
git clone https://github.com/SU-SWS/linky_clicky.git $BASEDIR/linky_clicky
cp $BASEDIR/linky_clicky/includes/features/SU-SWS/$TEST_FEATURE/$TEST_FEATURE.feature $BASEDIR/features/.
export DISPLAY=:99.0
sh -e /etc/init.d/xvfb start
sleep 3
