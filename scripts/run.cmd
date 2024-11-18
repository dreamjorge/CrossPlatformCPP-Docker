
@echo off

echo Running application in %CONFIG% mode.

REM Specify the absolute path to the executable
C:\app\build\%BUILD_TYPE%\CrossPlatformApp.exe

REM Optional: Capture exit code
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: Application execution failed with exit code %ERRORLEVEL%.
    exit /b %ERRORLEVEL%
) ELSE (
    echo Application executed successfully.
)