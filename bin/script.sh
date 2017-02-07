#!/bin/bash

# script
export PATH="$HOME/.composer/vendor/bin:$PATH"
export REPOSITORY_NAME=$(find $TRAVIS_BUILD_URL -mindepth 1 -maxdepth 1 -name "*.info" -type f -printf '%f\n' | cut -f1 -d".")
cd $HOME/stanford_travisci_scripts

# collect the list of feature files to run
BEHAT_TESTS=$(find features -name "*.feature" -type f -printf '%f\n')
echo "$BEHAT_TESTS"
FAILURES_COUNT=0

# run through each test, one at a time
for TEST in ${BEHAT_TESTS[@]}; do
  TEST_RESULT=$(timeout 3m bin/behat -p default -s all -f pretty features/$REPOSITORY_NAME/$TEST)
  if [[ $TEST_RESULT == *"Failed"* ]] || [[ $TEST_RESULT == *"Terminated"* ]]; then
    ((FAILURES_COUNT++))
    timeout 3m bin/behat -p default -s all -f pretty features/$REPOSITORY_NAME/$TEST
  fi
done

echo "Number of failed tests: $FAILURES_COUNT"

# remove behat tests for repository from cache
rm -rf $HOME/stanford_travisci_scripts/features/$REPOSITORY_NAME

# fail script.sh if behat returned at least one failure
if [ FAILURES_COUNT > 0 ]; then
  exit 1
else
  exit 0
fi
