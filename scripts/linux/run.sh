#!/bin/bash

# Exit on error
set -e

# Print the running mode
echo "Running application in $CONFIG mode."

# Set the build type based on CONFIG or default to Release
BUILD_TYPE=${CONFIG:-Release}

echo "BUILD_TYPE is $BUILD_TYPE"

# Specify potential paths for the executable
EXEC_PATH="./build/$BUILD_TYPE/CrossPlatformApp"
FALLBACK_PATH="./build/CrossPlatformApp"

# Determine the correct path to the executable
if [ -f "$EXEC_PATH" ]; then
    FINAL_EXEC_PATH="$EXEC_PATH"
elif [ -f "$FALLBACK_PATH" ]; then
    FINAL_EXEC_PATH="$FALLBACK_PATH"
else
    echo "ERROR: Executable not found at $EXEC_PATH or $FALLBACK_PATH!"
    exit 1
fi

echo "Executing: $FINAL_EXEC_PATH"
$FINAL_EXEC_PATH

echo "Application executed successfully."
