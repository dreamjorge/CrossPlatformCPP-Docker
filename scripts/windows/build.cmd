@echo off

:: Log start
echo Starting build.cmd > C:\app\build.log
echo CONFIG: %1 >> C:\app\build.log
echo VS_VERSION: %2 >> C:\app\build.log

:: Validate arguments
if "%~1"=="" (
    echo ERROR: Missing CONFIG argument (Debug/Release) >> C:\app\build.log
    exit /b 1
)
if "%~2"=="" (
    echo ERROR: Missing VS_VERSION argument (15/16/17) >> C:\app\build.log
    exit /b 1
)

:: Set variables from arguments
set CONFIG=%1
set VS_VERSION=%2

:: Log environment
echo Using CONFIG=%CONFIG% and VS_VERSION=%VS_VERSION% >> C:\app\build.log

:: Initialize Visual Studio environment
if "%VS_VERSION%"=="15" (
    set VS_DEV_CMD="C:\BuildTools\Common7\Tools\VsDevCmd.bat"
) else if "%VS_VERSION%"=="16" (
    set VS_DEV_CMD="C:\BuildTools\Common7\Tools\VsDevCmd.bat"
) else if "%VS_VERSION%"=="17" (
    set VS_DEV_CMD="C:\BuildTools\Common7\Tools\VsDevCmd.bat"
) else (
    echo ERROR: Unsupported VS_VERSION=%VS_VERSION% >> C:\app\build.log
    exit /b 1
)

:: Call Visual Studio environment
call %VS_DEV_CMD% >> C:\app\build.log 2>&1
if errorlevel 1 (
    echo ERROR: Failed to initialize Visual Studio environment >> C:\app\build.log
    exit /b 1
)

:: Run CMake commands
cmake -S C:\app -B C:\app\build -DCMAKE_BUILD_TYPE=%CONFIG% >> C:\app\build.log 2>&1
if errorlevel 1 (
    echo ERROR: CMake configuration failed >> C:\app\build.log
    exit /b 1
)

cmake --build C:\app\build --config %CONFIG% >> C:\app\build.log 2>&1
if errorlevel 1 (
    echo ERROR: Build failed >> C:\app\build.log
    exit /b 1
)

:: Success
echo Build completed successfully >> C:\app\build.log
exit /b 0
