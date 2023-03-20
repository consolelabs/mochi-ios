#!/bin/sh

#  ci_pre_xcodebuild.sh
#  Mochi Wallet
#
#  Created by Oliver Le on 21/03/2023.
#  

echo "Stage: PRE-Xcode Build is activated .... "
cd ../iOS/
plutil -replace MORALIS_API_KEY -string $MORALIS_API_KEY Secret.plist
plutil -p Secret.plist
echo "Stage: PRE-Xcode Build is DONE .... "

exit 0
