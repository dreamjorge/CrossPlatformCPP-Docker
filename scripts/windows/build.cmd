@echo off

:: Initialize logging
set LOG_FILE=%APP_WORKDIR%\build.log
echo Starting build process at %date% %time% > %LOG_FILE%
echo Logging to %LOG_FILE%

:: Validate arguments
if "%~1"=="" (
    echo ERROR: Missing CONFIG argument (Debug/Release) >> %LOG_FILE%
    exit /b 1
)
if "%~2"=="" (
    echo ERROR: Missing VS_VERSION argument (15/16/17) >> %LOG_FILE%
    exit /b 1
)

:: Set arguments to variables
set CONFIG=%1
set VS_VERSION=%2
echo Using CONFIG=%CONFIG% and VS_VERSION=%VS_VERSION% >> %LOG_FILE%

:: Log current directory and its contents
echo === Current Directory: %cd% === >> %LOG_FILE%
dir >> %LOG_FILE%
echo ================================= >> %LOG_FILE%

:: Initialize Visual Studio environment
if "%VS_VERSION%"=="15" (
    set VS_DEV_CMD="C:\BuildTools\Common7\Tools\VsDevCmd.bat"
) else if "%VS_VERSION%"=="16" (
    set VS_DEV_CMD="C:\BuildTools\Common7\Tools\VsDevCmd.bat"
) else if "%VS_VERSION%"=="17" (
    set VS_DEV_CMD="C:\BuildTools\Common7\Tools\VsDevCmd.bat"
) else (
    echo ERROR: Unsupported VS_VERSION=%VS_VERSION% >> %LOG_FILE%
    exit /b 1
)

:: Log Visual Studio environment initialization
echo Initializing Visual Studio environment with %VS_DEV_CMD% >> %LOG_FILE%
call %VS_DEV_CMD% >> %LOG_FILE% 2>&1
if errorlevel 1 (
    echo ERROR: Failed to initialize Visual Studio environment >> %LOG_FILE%
    exit /b 1
)

:: Validate CMake installation
echo Validating CMake installation... >> %LOG_FILE%
cmake --version >> %LOG_FILE% 2>&1
if errorlevel 1 (
    echo ERROR: CMake is not installed or not in PATH! >> %LOG_FILE%
    exit /b 1
)

:: Run CMake configuration
echo Running CMake configuration... >> %LOG_FILE%
cmake -S %APP_WORKDIR% -B %APP_WORKDIR%\build -DCMAKE_BUILD_TYPE=%CONFIG% >> %LOG_FILE% 2>&1
if errorlevel 1 (
    echo ERROR: CMake configuration failed >> %LOG_FILE%
    exit /b 1
)

:: Build project
echo Building project... >> %LOG_FILE%
cmake --build %APP_WORKDIR%\build --config %CONFIG% >> %LOG_FILE% 2>&1
if errorlevel 1 (
    echo ERROR: Build failed >> %LOG_FILE%
    exit /b 1
)

:: Success
echo Build completed successfully at %date% %time% >> %LOG_FILE%
exit /b 0
