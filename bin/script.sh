#!/bin/bash

# script
export PATH="$HOME/.composer/vendor/bin:$PATH"

# run through all tests in features directory
bin/behat -p default -s dev features

# grap the number of failures from behat's html output summary report
FAILURES_COUNT=$(cat behat_results/index.html | grep 'scenarios failed of' | sed -r 's/^([^.]+).*$/\1/; s/^[^0-9]*([0-9]+).*$/\1/')
echo "Number of failed tests: $FAILURES_COUNT"

# fail script.sh if behat returned at least one failure
if [ FAILURES_COUNT > 0 ]; then
  exit 1
else
  exit 0
fi
