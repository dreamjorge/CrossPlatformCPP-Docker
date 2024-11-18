#!/bin/bash

# Exit on error
set -e

# Print the configuration
echo "CONFIG is $CONFIG"

# Set the build type based on CONFIG or default to Release
BUILD_TYPE=${CONFIG:-Release}

echo "BUILD_TYPE is $BUILD_TYPE"
echo "Workspace Directory: $(pwd)"
echo "Listing files in current directory:"
ls -al

# Verify the presence of CMakeLists.txt
if [ ! -f "CMakeLists.txt" ]; then
    echo "ERROR: CMakeLists.txt not found!"
    exit 1
fi

# Verify CMake installation
if ! command -v cmake &> /dev/null; then
    echo "ERROR: CMake is not installed or not in PATH!"
    exit 1
fi

# Start the build process
echo "Starting build process..."
cmake -S . -B build -DCMAKE_BUILD_TYPE=$BUILD_TYPE
cmake --build build --config $BUILD_TYPE

echo "Build completed successfully."
