@echo off

echo CONFIG is %CONFIG%

IF NOT "%CONFIG%"=="" (
    SET BUILD_TYPE=%CONFIG%
) ELSE (
    SET BUILD_TYPE=Release
)

echo BUILD_TYPE is %BUILD_TYPE%
echo Current Directory: %CD%
echo Listing files in current directory:
dir

echo Verifying CMakeLists.txt presence:
if exist "CMakeLists.txt" (
    echo CMakeLists.txt found.
) else (
    echo ERROR: CMakeLists.txt not found!
    exit /b 1
)

CALL "C:\BuildTools\Common7\Tools\VsDevCmd.bat" && ^
cmake -S . -B build -G "Visual Studio 17 2022" -A x64 && ^
cmake --build build --config %BUILD_TYPE%
