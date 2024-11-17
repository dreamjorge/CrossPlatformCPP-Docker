@echo off
SET BUILD_TYPE=%1
IF "%BUILD_TYPE%"=="" SET BUILD_TYPE=Release

CALL C:\BuildTools\Common7\Tools\VsDevCmd.bat &&
cmake -S . -B build -G "Visual Studio 16 2019" -A x64 &&
cmake --build build --config %BUILD_TYPE%