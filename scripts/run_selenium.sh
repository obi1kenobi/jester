#!/usr/bin/env bash

# stop immediately if the process returns non-zero exit code
set -e

# sanity check
if [ "$0" != "./scripts/run_selenium.sh" ]; then
  echo "Start failed: Wrong cwd"
  echo "Executed from wrong cwd, you need to be in the jester root to call this script"
  exit 1
fi

java -jar ./selenium/selenium-server-standalone-2.46.0.jar -Dwebdriver.chrome.driver="../selenium/chromedriver.exe"
