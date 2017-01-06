#!/bin/bash

cd $BASEDIR/linky_clicky/sites/$TEST_FEATURE
behat -vvv -p default -s all features
