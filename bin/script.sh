#!/bin/bash

# script
export PATH="$HOME/.composer/vendor/bin:$PATH"
cd $HOME/stanford_travisci_scripts

# collect the list of feature files to run
BEHAT_TESTS=$(find features -name "*.feature" -type f -printf '%f\n')
echo "$BEHAT_TESTS"
FAILURES_COUNT=0

# re-assign value for profile variable
PROFILE_NAME=$(find $TRAVIS_BUILD_DIR/html/profiles -name "*jumpstart*" -type d -printf '%f\n')
if [ -z "$PROFILE_NAME" ]; then PROFILE_NAME="stanford"; fi

# reinstall site once after first behat test failure
function reinstall_rerun_on_first_failure {
  drush @local si $PROFILE_NAME -y >/dev/null
  TEST_RESULT=$(timeout 3m bin/behat -p default -s all -f pretty features/$REPOSITORY_NAME/$TEST)
  if [[ $TEST_RESULT == *"Failed"* ]] || [[ $TEST_RESULT == *"Terminated"* ]]; then
    ((FAILURES_COUNT++))
    timeout 3m bin/behat -p default -s all -f pretty features/$REPOSITORY_NAME/$TEST
  fi
}

# determine whether the test passed or failed
# increment failure count if test failed
function evaluate_first_test_result {
  if [[ $TEST_RESULT == *"Failed"* ]] || [[ $TEST_RESULT == *"Terminated"* ]]; then
    reinstall_rerun_on_first_failure
  fi
}

# run through each test, one at a time
# (1) output results to shell and (2) save as variable, ie. 1>&2
for TEST in ${BEHAT_TESTS[@]}; do
  TEST_RESULT=$(timeout 3m bin/behat -p default -s all -f pretty features/$REPOSITORY_NAME/$TEST)
  evaluate_first_test_result
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
