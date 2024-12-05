@echo off

echo Running application in %CONFIG% mode.

:: Determine BUILD_TYPE based on CONFIG
if not "%CONFIG%"=="" (
    set BUILD_TYPE=%CONFIG%
) else (
    set BUILD_TYPE=Release
)

echo BUILD_TYPE is %BUILD_TYPE%

:: Specify the absolute path to the executable based on the build type
set EXEC_PATH=%APP_WORKDIR%\build\%BUILD_TYPE%\CrossPlatformApp.exe

echo Executing: %EXEC_PATH%

:: Execute the application
"%EXEC_PATH%"

:: Capture and handle the exit code
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Application execution failed with exit code %ERRORLEVEL%.
    exit /b %ERRORLEVEL%
) else (
    echo Application executed successfully.
)
