@echo off
setlocal

:: Define Visual Studio versions and years
set "VS_VERSION_2017=15"
set "VS_VERSION_2019=16"
set "VS_VERSION_2022=17"

:: Set default Visual Studio year and version if not set
if "%VS_YEAR%"=="" (
    echo INFO: VS_YEAR not set. Defaulting to 2019.
    set "VS_YEAR=2019"
    set "VS_VERSION=%VS_VERSION_2019%"
) else (
    call :get_vs_version %VS_YEAR%
    if errorlevel 1 exit /b 1
)

:: Debugging: Print environment variables and list directories
echo VS_YEAR=%VS_YEAR%
echo VS_VERSION=%VS_VERSION%
echo CONFIG=%CONFIG%
echo Current directory:
cd
echo Listing C:\app\scripts\windows:
dir C:\app\scripts\windows

:: Verify CMake installation
echo Verifying CMake installation:
cmake --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: CMake is not installed or not in PATH!
    exit /b 1
)

:: Dynamically locate VsDevCmd.bat
for /f "delims=" %%I in ('powershell -Command "(Get-ChildItem -Path 'C:\Program Files (x86)\Microsoft Visual Studio\' -Recurse -Filter VsDevCmd.bat | Sort-Object -Property FullName -Descending | Select-Object -First 1).FullName"') do set "VS_DEV_CMD=%%I"

if not exist "%VS_DEV_CMD%" (
    echo ERROR: VsDevCmd.bat not found.
    exit /b 1
)

:: Start the Visual Studio environment and build process
echo Starting build process for Visual Studio %VS_YEAR%...
CALL "%VS_DEV_CMD%" ^
    && cmake -S . -B build -G "Visual Studio %VS_VERSION% %VS_YEAR%" -A x64 ^
    && cmake --build build --config %CONFIG%

:: Check if the build was successful
if errorlevel 1 (
    echo ERROR: Build failed!
    exit /b 1
) else (
    echo Build completed successfully.
)
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