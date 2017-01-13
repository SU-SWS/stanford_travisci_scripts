#!/bin/bash

# before_script
# download linky_clicky and copy over related tests
git clone https://github.com/SU-SWS/linky_clicky.git
cp linky_clicky/includes/features/SU-SWS/$TEST_FEATURE stanford_travisci_scripts/features/.
ls stanford_travisci_scripts/features

# start xvfb virtual display
export DISPLAY=:99.0
sh -e /etc/init.d/xvfb start

# give xvfb time to launch before running tests
sleep 3
