@echo off
SET BUILD_TYPE=%1
IF "%BUILD_TYPE%"=="" SET BUILD_TYPE=Release

C:\build\build\%BUILD_TYPE%\CrossPlatformApp.exe