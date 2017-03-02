#!/bin/bash

# functions used by before_script.sh to determine which tests should be run
# copy over production product tests
function copy_product_tests {
  declare -A PRODUCTS_LIST=(
    ["jumpstart-academic"]="jsa"
    ["jumpstart-engineering"]="jse"
    ["jumpstart-plus"]="jsplus"
    ["jumpstart"]="jsv"
    ["jumpstart-lab"]="jsl"
  )
  ACRONYM="${PRODUCTS_LIST[$PRODUCT_NAME]}"
  if [ ! -z "$ACRONYM" ]; then
    echo "cp -r $HOME/linky_clicky/products/$ACRONYM/features $HOME/stanford_travisci_scripts/features/$REPOSITORY_NAME"
    cp -r $HOME/linky_clicky/products/$ACRONYM/features $HOME/stanford_travisci_scripts/features/$REPOSITORY_NAME
  fi
}

function copy_uat_tests {
  cp -r $HOME/linky_clicky/sites/uat/features $HOME/stanford_travisci_scripts/features/$REPOSITORY_NAME
  # remove mollom, so long as it remains unencrypted
  rm $HOME/stanford_travisci_scripts/features/$REPOSITORY_NAME/mollom.feature
}

function copy_module_tests {
  cp -r $HOME/linky_clicky/includes/features/SU-SWS/$REPOSITORY_NAME $HOME/stanford_travisci_scripts/features/.
}

# loop through and copy specific tests called for by ONLY_TEST variable
function copy_single_test {
  mkdir $HOME/stanford_travisci_scripts/features/$REPOSITORY_NAME
  TESTS=(`echo ${ONLY_TEST}`)
  for TEST in ${TESTS[@]}; do
    TEST_PATH=$(find $HOME/linky_clicky -type f -name "$TEST.feature")
    cp $TEST_PATH $HOME/stanford_travisci_scripts/features/$REPOSITORY_NAME/$TEST.feature
  done
}
