#!/bin/bash

cd $BASEDIR/linky_clicky/sites/uat
$BASEDIR/linky_clicky/bin/behat -vvv features/stanford_bean_types.feature
