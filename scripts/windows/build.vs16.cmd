@echo off

:: Print the configuration
echo CONFIG is %CONFIG%

:: Set the build type based on CONFIG or default to Release
IF NOT "%CONFIG%"=="" (
    SET BUILD_TYPE=%CONFIG%
) ELSE (
    SET BUILD_TYPE=Release
)

:: Display the selected build type and directory details
echo BUILD_TYPE is %BUILD_TYPE%
echo BUILD_DIR is %BUILD_DIR%
echo Current Directory: %CD%
echo Listing files in current directory:
dir

:: Verify the presence of CMakeLists.txt
echo Verifying CMakeLists.txt presence:
if exist "CMakeLists.txt" (
    echo CMakeLists.txt found.
) else (
    echo ERROR: CMakeLists.txt not found!
    exit /b 1
)

:: Verify CMake installation
echo Verifying CMake installation:
cmake --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: CMake is not installed or not in PATH!
    exit /b 1
)

:: Start the Visual Studio environment and build process
echo Starting build process...
CALL "C:\BuildTools\Common7\Tools\VsDevCmd.bat" ^
    && cmake -S . -B build -G "Visual Studio 16 2019" -A x64 ^
    && cmake --build build --config %BUILD_TYPE%

:: Check if the build was successful
if errorlevel 1 (
    echo ERROR: Build failed!
    exit /b 1
) else (
    echo Build completed successfully.
)
