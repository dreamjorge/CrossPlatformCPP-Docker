@echo off

:: ============================
:: Helper Functions
:: ============================
:Log
echo [%DATE% %TIME%] %~1
goto :EOF

:ErrorExit
echo [%DATE% %TIME%] ERROR: %~1
exit /b 1

:: ============================
:: Set Default Values
:: ============================
SET CONFIG=Release
SET VS_VERSION=

:: ============================
:: Parse Arguments
:: ============================
IF NOT "%1"=="" (
    SET VS_VERSION=%1
) ELSE (
    CALL :ErrorExit "No Visual Studio version specified! Usage: build.cmd [15|16|17] [Debug|Release]"
)

IF NOT "%2"=="" (
    SET CONFIG=%2
)

:: ============================
:: Validate Visual Studio Version
:: ============================
IF "%VS_VERSION%"=="15" (
    SET VS_GENERATOR=Visual Studio 15 2017
) ELSE IF "%VS_VERSION%"=="16" (
    SET VS_GENERATOR=Visual Studio 16 2019
) ELSE IF "%VS_VERSION%"=="17" (
    SET VS_GENERATOR=Visual Studio 17 2022
) ELSE (
    CALL :ErrorExit "Invalid Visual Studio version specified! Use 15, 16, or 17."
)

:: ============================
:: Validate CONFIG
:: ============================
IF NOT "%CONFIG%"=="Debug" IF NOT "%CONFIG%"=="Release" (
    CALL :ErrorExit "Invalid CONFIG specified! Use Debug or Release."
)

:: ============================
:: Log Configuration
:: ============================
CALL :Log "Visual Studio Version: %VS_VERSION% [%VS_GENERATOR%]"
CALL :Log "Build Configuration: %CONFIG%"
CALL :Log "Current Directory: %CD%"

:: ============================
:: Verify CMakeLists.txt Presence
:: ============================
CALL :Log "Verifying CMakeLists.txt presence..."
if exist "CMakeLists.txt" (
    CALL :Log "CMakeLists.txt found."
) else (
    CALL :ErrorExit "CMakeLists.txt not found!"
)

:: ============================
:: Verify CMake Installation
:: ============================
CALL :Log "Verifying CMake installation..."
cmake --version >nul 2>&1
if errorlevel 1 (
    CALL :ErrorExit "CMake is not installed or not in PATH!"
)

:: ============================
:: Start Build Process
:: ============================
CALL :Log "Starting build process..."
CALL "C:\BuildTools\Common7\Tools\VsDevCmd.bat" ^
    && cmake -S . -B build -G "%VS_GENERATOR%" -A x64 > build_logs.txt 2>&1 ^
    && cmake --build build --config %CONFIG% --verbose >> build_logs.txt 2>&1

if errorlevel 1 (
    CALL :ErrorExit "Build failed! See build_logs.txt for details."
) else (
    CALL :Log "Build completed successfully. See build_logs.txt for details."
)

:: ============================
:: Display Build Logs
:: ============================
type build_logs.txt

:: ============================
:: Exit Successfully
:: ============================
exit /b 0
