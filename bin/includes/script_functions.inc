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
    cp -rL $HOME/linky_clicky/products/$ACRONYM/features $HOME/stanford_travisci_scripts/features/$REPOSITORY_NAME
  fi
}

function copy_uat_tests {
  cp -rL $HOME/linky_clicky/sites/uat/features/high-value $HOME/stanford_travisci_scripts/features/$REPOSITORY_NAME
  # remove mollom and capx features, so long as they remain unencrypted
  rm $HOME/stanford_travisci_scripts/features/$REPOSITORY_NAME/mollom.feature
  rm $HOME/stanford_travisci_scripts/features/$REPOSITORY_NAME/stanford_capx.feature
}

function copy_module_tests {
  cp -rL $HOME/linky_clicky/includes/features/SU-SWS/$REPOSITORY_NAME $HOME/stanford_travisci_scripts/features/.
}

# find and copy assets when running uat tests
function copy_assets {
  mkdir $HOME/stanford_travisci_scripts/img
  declare -a ASSET_EXTENSIONS=("*.png" "*.jpg" "*.txt" "*.mp4" "*.srt")
  for EXTENSION in ${ASSET_EXTENSIONS[@]}; do
    find $HOME/linky_clicky -type f -name "$EXTENSION"
    find $HOME/linky_clicky -type f -name "$EXTENSION" -exec cp {} $HOME/stanford_travisci_scripts/img/ \;
  done
  # find not locating filefield_path.txt file
  cp $HOME/linky_clicky/sites/uat/img/filefield_path.txt $HOME/stanford_travisci_scripts/img/
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
