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
  cp -r $HOME/linky_clicky/sites/uat/features/high-value $HOME/stanford_travisci_scripts/features/$REPOSITORY_NAME
  # remove mollom and capx features, so long as they remain unencrypted
  rm $HOME/stanford_travisci_scripts/features/$REPOSITORY_NAME/mollom.feature
  rm $HOME/stanford_travisci_scripts/features/$REPOSITORY_NAME/stanford_capx.feature
}

function copy_module_tests {
  cp -r $HOME/linky_clicky/includes/features/SU-SWS/$REPOSITORY_NAME $HOME/stanford_travisci_scripts/features/.
}

# find and copy assets when running a single test
function copy_assets {
  mkdir $HOME/stanford_travisci_scripts/features/img
  ASSETS_FOUND=$(find $HOME/linky_clicky -type f -name "*.png" -o -name "*.jpg")
  echo "$ASSETS_FOUND"
  find $HOME/linky_clicky -type f -name "*.png" -exec cp {} $HOME/stanford_travisci_scripts/features/img/ \;
  find $HOME/linky_clicky -type f -name "*.jpg" -exec cp {} $HOME/stanford_travisci_scripts/features/img/ \;
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
