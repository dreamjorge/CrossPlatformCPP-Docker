#!/bin/bash

# Map VS_YEAR to VS_VERSION
if [ "$1" == "2017" ]; then
  echo "VS_VERSION=15" >> $GITHUB_ENV
elif [ "$1" == "2019" ]; then
  echo "VS_VERSION=16" >> $GITHUB_ENV
elif [ "$1" == "2022" ]; then
  echo "VS_VERSION=17" >> $GITHUB_ENV
else
  echo "Unsupported Visual Studio year: $1"
  exit 1
fi