#!/bin/bash

# script
export PATH="$HOME/.composer/vendor/bin:$PATH"
cd $HOME/stanford_travisci_scripts

# collect the list of feature files to run
BEHAT_TESTS=$(find features -name "*.feature" -type f -printf '%f\n')
echo "$BEHAT_TESTS"
FAILURES_COUNT=0
FAILURES_DETAIL=()

# reinstall site once after first behat test failure
function reinstall_rerun_on_first_failure {
  drush @local si stanford -y
  TEST_RESULT=$(timeout 3m bin/behat -p default -s all -f pretty features/$REPOSITORY_NAME/$TEST 1>&2)
  if [[ $TEST_RESULT == *"Failed"* ]] || [[ $TEST_RESULT == *"Terminated"* ]]; then
    ((FAILURES_COUNT++))
    FAILURES_DETAIL+=$TEST_RESULT
  fi
}

# determine whether the test passed or failed
# increment failure count if test failed
function evaluate_first_test_result {
  if [[ $TEST_RESULT == *"Failed"* ]] || [[ $TEST_RESULT == *"Terminated"* ]]; then
    reinstall-rerun_on_first_failure
  fi
}

# run through each test, one at a time
# (1) output results to shell and (2) save as variable, ie. 1>&2
for TEST in ${BEHAT_TESTS[@]}; do
  TEST_RESULT=$(timeout 3m bin/behat -p default -s all -f pretty features/$REPOSITORY_NAME/$TEST 1>&2)
  evaluate_first_test_result
done

echo "${FAILURES_DETAIL[*]}"

# fail script.sh if behat returned at least one failure
if [[ FAILURES_COUNT > 0 ]]; then
  exit 1
else
  exit 0
fi
