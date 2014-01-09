#!/bin/bash

while :; do # Loop until valid input is entered or Cancel is pressed.
      appId=$(osascript -e 'Tell application "System Events" to display dialog "Enter the Splitforce App ID:" default answer ""' -e 'text returned of result' 2>/dev/null)
      if (( $? )); then exit 1; fi  # Abort, if user pressed Cancel.
      appId=$(echo -n "$appId" | sed 's/^ *//' | sed 's/ *$//')  # Trim leading and trailing whitespace.
      if [[ -z "$appId" ]]; then
            # The user left the project appId blank.
            osascript -e 'Tell application "System Events" to display alert "You must enter a non-blank App ID; please try again." as warning' >/dev/null
            # Continue loop to prompt again.
      else
            # Valid input: exit loop and continue.
           break
      fi
done

while :; do # Loop until valid input is entered or Cancel is pressed.
      appKey=$(osascript -e 'Tell application "System Events" to display dialog "Enter the Splitforce App Key:" default answer ""' -e 'text returned of result' 2>/dev/null)
      if (( $? )); then exit 1; fi  # Abort, if user pressed Cancel.
      appKey=$(echo -n "$appKey" | sed 's/^ *//' | sed 's/ *$//')  # Trim leading and trailing whitespace.
      if [[ -z "$appKey" ]]; then
          # The user left the project appKey blank.
          osascript -e 'Tell application "System Events" to display alert "You must enter a non-blank App Key; please try again." as warning' >/dev/null
          # Continue loop to prompt again.
      else
          # Valid input: exit loop and continue.
          break
      fi
done

echo "// This is an auto-generated file, do not edit manually as your changes may be lost.  Run genKeys.sh to change the values in this file." > privateKeys.h
echo "// " >> privateKeys.h
echo "#define kSplitforceAppId @\""$appId"\"" >> privateKeys.h
echo "#define kSplitforceAppKey @\""$appKey"\"" >> privateKeys.h
