#!/bin/bash

# before_script
cd ../
TEST_FEATURE=$(ls *.info | cut -f1 -d".")
git clone https://github.com/SU-SWS/linky_clicky.git $BASEDIR/linky_clicky
cd $BASEDIR/linky_clicky
mkdir sites/$TEST_FEATURE
mv $BASEDIR/features sites/$TEST_FEATURE
mv $BASEDIR/behat.yml sites/$TEST_FEATURE
cp sites/uat/features/$TEST_FEATURE*.feature $BASEDIR/linky_clicky/sites/$TEST_FEATURE/features/.
