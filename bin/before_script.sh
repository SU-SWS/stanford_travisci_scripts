#!/bin/bash

# before_script
cd ../
TEST_FEATURE=$(ls *.info | cut -f1 -d".")
git clone https://github.com/SU-SWS/linky_clicky.git $BASEDIR/linky_clicky
cp $BASEDIR/linky_clicky/sites/uat/features/$TEST_FEATURE.feature $BASEDIR/features/.
