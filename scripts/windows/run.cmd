@echo off

:: ============================
:: Log Configuration
:: ============================
IF NOT "%CONFIG%"=="" (
    SET BUILD_TYPE=%CONFIG%
) ELSE (
    SET BUILD_TYPE=Release
)

echo Running application in %BUILD_TYPE% mode.
SET EXEC_PATH=C:\app\build\%BUILD_TYPE%\CrossPlatformApp.exe

:: ============================
:: Validate Application Path
:: ============================
IF NOT EXIST "%EXEC_PATH%" (
    echo ERROR: Application executable not found at %EXEC_PATH%!
    exit /b 1
)

:: ============================
:: Run Application
:: ============================
echo Executing: %EXEC_PATH%
"%EXEC_PATH%"
IF ERRORLEVEL 1 (
    echo ERROR: Application execution failed with exit code %ERRORLEVEL%.
    exit /b %ERRORLEVEL%
)

echo Application executed successfully.
exit /b 0
