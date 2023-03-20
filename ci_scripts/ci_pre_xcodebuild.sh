#!/bin/sh

#  ci_pre_xcodebuild.sh
#  Mochi Wallet
#
#  Created by Oliver Le on 21/03/2023.
#  

echo "Stage: PRE-Xcode Build is activated .... "
# This is important because the position of the subsequently mentioned files depend of this origin.
cd $CI_WORKSPACE/ci_scripts || exit 1
plutil -replace MORALIS_API_KEY -string $MORALIS_API_KEY ../iOS/Supports/Secret.plist
plutil -p ../iOS/Supports/Secret.plist
echo "Stage: PRE-Xcode Build is DONE .... "

exit 0
