#!/bin/bash

cd $BASEDIR/linky_clicky/sites/$TEST_FEATURE
$BASEDIR/linky_clicky/bin/behat -vvv -p default -s all features
