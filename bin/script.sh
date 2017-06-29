#!/bin/bash

# script
export PATH="$HOME/.composer/vendor/bin:$PATH"
export REPOSITORY_NAME=$(basename $TRAVIS_BUILD_DIR)

# run through all tests in features directory
cd $HOME/stanford_travisci_scripts

if [[ -z "$BEHAT_TAG" ]]; then
  TAGS='~@sites&&~@webauth&&~@email'
else
  TAGS="@$BEHAT_TAG&&~@sites&&~@webauth&&~@email"
fi

bin/behat -p default -s dev --tags "$TAGS" --colors -vvv features


# grap the number of failures from behat's html output summary report
FAILURES_COUNT=$(cat behat_results/index.html | grep 'scenarios failed of' | sed -r 's/^([^.]+).*$/\1/; s/^[^0-9]*([0-9]+).*$/\1/')
FEATURE_FILES=$(find $HOME/stanford_travisci_scripts/features/$REPOSITORY_NAME -type f -name "*.feature")

echo "Number of failed tests: $FAILURES_COUNT"

# upload failed test screenshots
$HOME/stanford_travisci_scripts/bin/upload-screenshots "$HOME/lakion/*.png"

# fail script.sh if behat returned at least one failure
if [ -z "$FAILURES_COUNT" ] || [ -z "$FEATURE_FILES" ]; then
  exit 1
elif (( $FAILURES_COUNT > 0 )); then
  exit 1
else
  exit 0
fi
