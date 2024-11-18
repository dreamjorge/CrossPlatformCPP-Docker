@echo off

echo Running application in %CONFIG% mode.

REM Determine BUILD_TYPE based on CONFIG
IF NOT "%CONFIG%"=="" (
    SET BUILD_TYPE=%CONFIG%
) ELSE (
    SET BUILD_TYPE=Release
)

echo BUILD_TYPE is %BUILD_TYPE%

REM Specify the absolute path to the executable based on the build type
SET EXEC_PATH=C:\app\build\%BUILD_TYPE%\CrossPlatformApp.exe

echo Executing: %EXEC_PATH%

REM Execute the application
"%EXEC_PATH%"

REM Capture and handle the exit code
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Application execution failed with exit code %ERRORLEVEL%.
    exit /b %ERRORLEVEL%
) ELSE (
    echo Application executed successfully.
)
