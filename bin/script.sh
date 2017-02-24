#!/bin/bash

# script
export PATH="$HOME/.composer/vendor/bin:$PATH"
export REPOSITORY_NAME=$(basename $TRAVIS_BUILD_DIR)

# run through all tests in features directory
cd $HOME/stanford_travisci_scripts
bin/behat -p default -s dev features

# grap the number of failures from behat's html output summary report
FAILURES_COUNT=$(cat behat_results/index.html | grep 'scenarios failed of' | sed -r 's/^([^.]+).*$/\1/; s/^[^0-9]*([0-9]+).*$/\1/')
TESTS_COUNT=$(basename `find $HOME/stanford_travisci_scripts/features/$REPOSITORY_NAME -type f -name "*.feature"` | grep -c ".feature")

echo "Number of failed tests: $FAILURES_COUNT"
echo "Number of tests counted: $TESTS_COUNT"

# fail script.sh if behat returned at least one failure
if (( $FAILURES_COUNT > 0 )) || (( $TESTS_COUNT > 0 )); then
  exit 1
else
  exit 0
fi
