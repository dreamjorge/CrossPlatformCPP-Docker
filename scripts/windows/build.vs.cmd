@echo off
setlocal

:: Define a dictionary-like structure for Visual Studio versions and years
set "VS_VERSION_2017=15"
set "VS_VERSION_2019=16"
set "VS_VERSION_2022=17"

:: Function to get the Visual Studio version based on the year
call :get_vs_version %VS_YEAR%
goto :eof

:get_vs_version
if "%1"=="2017" (
    set "VS_VERSION=%VS_VERSION_2017%"
) else if "%1"=="2019" (
    set "VS_VERSION=%VS_VERSION_2019%"
) else if "%1"=="2022" (
    set "VS_VERSION=%VS_VERSION_2022%"
) else (
    echo ERROR: Unsupported Visual Studio year: %1
    exit /b 1
)
goto :eof

:: Debugging: Print environment variables and list directories
echo VS_YEAR=%VS_YEAR%
echo VS_VERSION=%VS_VERSION%
echo CONFIG=%CONFIG%
echo Current directory:
cd
echo Listing C:\scripts\windows:
dir C:\scripts\windows

:: Verify CMake installation
echo Verifying CMake installation:
cmake --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: CMake is not installed or not in PATH!
    exit /b 1
)

:: Start the Visual Studio environment and build process
echo Starting build process for Visual Studio %VS_YEAR%...
CALL "C:\BuildTools\Common7\Tools\VsDevCmd.bat" ^
    && cmake -S . -B build -G "Visual Studio %VS_VERSION% %VS_YEAR%" -A x64 ^
    && cmake --build build --config %CONFIG%

:: Check if the build was successful
if errorlevel 1 (
    echo ERROR: Build failed!
    exit /b 1
) else (
    echo Build completed successfully.
)