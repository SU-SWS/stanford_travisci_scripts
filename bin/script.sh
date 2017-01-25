#!/bin/bash

# script
export PATH="$HOME/.composer/vendor/bin:$PATH"
cd stanford_travisci_scripts

# collect the list of feature files to run
BEHAT_TESTS=$(find features -name "*.feature" -type f -printf '%f\n')
echo "$BEHAT_TESTS"
FAILURES=0

# determine whether the test passed or failed
# increment failure count if test failed
function evaluate_test_result {
  if [[ $TEST_RESULT == *"Failed"* ]] || [[ $TEST_RESULT == *"Terminated"* ]]; then
    ((FAILURES++))
  fi
}

# run through each test, one at a time
# (1) output results to shell and (2) save as variable, ie. 1>&2
for TEST in ${BEHAT_TESTS[@]}; do
  TEST_RESULT=$(timeout 3m bin/behat -p default -s all -f pretty features/$REPOSITORY_NAME/$TEST 1>&2)
  evaluate_test_result
done

# fail script.sh if behat returned at least one failure
if [[ FALIURES > 0 ]]; then
  exit 1
else
  exit 0
fi
