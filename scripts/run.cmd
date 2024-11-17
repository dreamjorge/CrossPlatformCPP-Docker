@echo off

echo Running application in %BUILD_TYPE% mode.

REM Navigate to the build output directory
cd build\%BUILD_TYPE%

REM Execute the application
CrossPlatformApp.exe