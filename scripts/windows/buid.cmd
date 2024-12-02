@echo off

:: Set default values for CONFIG and VS_VERSION
SET CONFIG=Release
SET VS_VERSION=

:: Parse arguments
IF NOT "%1"=="" (
    SET VS_VERSION=%1
) ELSE (
    echo ERROR: No Visual Studio version specified! Usage: build.cmd [15|16|17] [Debug|Release]
    exit /b 1
)

IF NOT "%2"=="" (
    SET CONFIG=%2
)

:: Validate Visual Studio version
IF "%VS_VERSION%"=="15" (
    SET VS_GENERATOR=Visual Studio 15 2017
) ELSE IF "%VS_VERSION%"=="16" (
    SET VS_GENERATOR=Visual Studio 16 2019
) ELSE IF "%VS_VERSION%"=="17" (
    SET VS_GENERATOR=Visual Studio 17 2022
) ELSE (
    echo ERROR: Invalid Visual Studio version specified! Use 15, 16, or 17.
    exit /b 1
)

:: Validate CONFIG
IF NOT "%CONFIG%"=="Debug" IF NOT "%CONFIG%"=="Release" (
    echo ERROR: Invalid CONFIG specified! Use Debug or Release.
    exit /b 1
)

:: Print configuration
echo Visual Studio Version: %VS_VERSION% [%VS_GENERATOR%]
echo Build Configuration: %CONFIG%

:: Display the selected build type and directory details
echo BUILD_TYPE is %CONFIG%
echo BUILD_DIR is %BUILD_DIR%
echo Current Directory: %CD%
echo Listing files in current directory:
dir

:: Verify the presence of CMakeLists.txt
echo Verifying CMakeLists.txt presence:
if exist "CMakeLists.txt" (
    echo CMakeLists.txt found.
) else (
    echo ERROR: CMakeLists.txt not found!
    exit /b 1
)

:: Verify CMake installation
echo Verifying CMake installation:
cmake --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: CMake is not installed or not in PATH!
    exit /b 1
)

:: Start the Visual Studio environment and build process
echo Starting build process...
CALL "C:\BuildTools\Common7\Tools\VsDevCmd.bat" ^
    && cmake -S . -B build -G "%VS_GENERATOR%" -A x64 ^
    && cmake --build build --config %CONFIG%

:: Check if the build was successful
if errorlevel 1 (
    echo ERROR: Build failed!
    exit /b 1
) else (
    echo Build completed successfully.
)
