@echo off

:: Log start
echo Starting build.cmd > %APP_WORKDIR%\build.log
echo CONFIG: %1 >> %APP_WORKDIR%\build.log
echo VS_VERSION: %2 >> %APP_WORKDIR%\build.log

:: Validate arguments
if "%~1"=="" (
    echo ERROR: Missing CONFIG argument (Debug/Release) >> %APP_WORKDIR%\build.log
    exit /b 1
)
if "%~2"=="" (
    echo ERROR: Missing VS_VERSION argument (15/16/17) >> %APP_WORKDIR%\build.log
    exit /b 1
)

:: Set variables from arguments
set CONFIG=%1
set VS_VERSION=%2

:: Log environment
echo Using CONFIG=%CONFIG% and VS_VERSION=%VS_VERSION% >> %APP_WORKDIR%\build.log

:: Initialize Visual Studio environment
if "%VS_VERSION%"=="15" (
    set VS_DEV_CMD="C:\BuildTools\Common7\Tools\VsDevCmd.bat"
) else if "%VS_VERSION%"=="16" (
    set VS_DEV_CMD="C:\BuildTools\Common7\Tools\VsDevCmd.bat"
) else if "%VS_VERSION%"=="17" (
    set VS_DEV_CMD="C:\BuildTools\Common7\Tools\VsDevCmd.bat"
) else (
    echo ERROR: Unsupported VS_VERSION=%VS_VERSION% >> %APP_WORKDIR%\build.log
    exit /b 1
)

:: Call Visual Studio environment
call %VS_DEV_CMD% >> %APP_WORKDIR%\build.log 2>&1
if errorlevel 1 (
    echo ERROR: Failed to initialize Visual Studio environment >> %APP_WORKDIR%\build.log
    exit /b 1
)

:: Run CMake commands
cmake -S %APP_WORKDIR% -B %APP_WORKDIR%\build -DCMAKE_BUILD_TYPE=%CONFIG% >> %APP_WORKDIR%\build.log 2>&1
if errorlevel 1 (
    echo ERROR: CMake configuration failed >> %APP_WORKDIR%\build.log
    exit /b 1
)

cmake --build %APP_WORKDIR%\build --config %CONFIG% >> %APP_WORKDIR%\build.log 2>&1
if errorlevel 1 (
    echo ERROR: Build failed >> %APP_WORKDIR%\build.log
    exit /b 1
)

:: Success
echo Build completed successfully >> %APP_WORKDIR%\build.log
exit /b 0
