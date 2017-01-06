#!/bin/bash

cd $BASEDIR/linky_clicky/sites/$TEST_FEATURE
$BASEDIR/vendor/bin/behat -p default -s all features
