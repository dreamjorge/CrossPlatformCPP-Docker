@echo off

:: Unified build script with minimized redundancy

:: Function: Print error message and exit
:exitWithError
echo ERROR: %1
exit /b 1

:: Input arguments
SET CONFIG=%1
SET VS_VERSION=%2

:: Default values if not provided
IF "%CONFIG%"=="" SET CONFIG=Release
IF "%VS_VERSION%"=="" SET VS_VERSION=17

:: Set the build type
SET BUILD_TYPE=%CONFIG%
echo CONFIG: %CONFIG%
echo VS_VERSION: %VS_VERSION%
echo BUILD_TYPE: %BUILD_TYPE%

:: Verify the presence of CMakeLists.txt
echo Verifying CMakeLists.txt presence:
if not exist "CMakeLists.txt" call :exitWithError "CMakeLists.txt not found!"

:: Verify CMake installation
echo Verifying CMake installation:
cmake --version >nul 2>&1 || call :exitWithError "CMake is not installed or not in PATH!"

:: Determine the Visual Studio environment script and CMake generator
SET CMAKE_GENERATOR=
IF "%VS_VERSION%"=="15" (
    SET VS_DEV_CMD="C:\BuildTools\Common7\Tools\VsDevCmd.bat"
    SET CMAKE_GENERATOR="Visual Studio 15 2017"
) ELSE IF "%VS_VERSION%"=="16" (
    SET VS_DEV_CMD="C:\BuildTools\Common7\Tools\VsDevCmd.bat"
    SET CMAKE_GENERATOR="Visual Studio 16 2019"
) ELSE IF "%VS_VERSION%"=="17" (
    SET VS_DEV_CMD="C:\BuildTools\Common7\Tools\VsDevCmd.bat"
    SET CMAKE_GENERATOR="Visual Studio 17 2022"
) ELSE (
    call :exitWithError "Unsupported Visual Studio version: %VS_VERSION%"
)

:: Build process
echo Starting build process with VS_VERSION=%VS_VERSION% and CONFIG=%CONFIG%...
CALL %VS_DEV_CMD% ^
    && cmake -S . -B build -G %CMAKE_GENERATOR% -A x64 ^
    && cmake --build build --config %BUILD_TYPE% || call :exitWithError "Build failed!"

echo Build completed successfully!
exit /b 0
