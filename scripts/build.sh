#!/usr/bin/env bash

# stop immediately if any process returns non-zero exit code
set -e

# sanity check:
# this script deletes files left and right
# make sure that it's deleting the right ones
if [ "$0" != "./scripts/build.sh" ]; then
  echo "Build failed: Wrong cwd"
  echo "Executed from wrong cwd, you need to be in the jester root to call this script"
  exit 1
fi

echo "Removing existing build..."
rm -rf ./bin && mkdir ./bin

# compile with source maps
echo "Compiling Coffeescript to JS..."
./node_modules/.bin/coffee --map --output ./bin/js --compile ./src/js

echo "Linting..."
find ./src/js -name "*.coffee" -print0 | xargs -0 ./node_modules/.bin/coffeelint -f ./coffeelint.json

echo "Build successful!"
