@echo off

IF NOT "%1"=="" (
    SET BUILD_TYPE=%1
) ELSE IF NOT "%CONFIG%"=="" (
    SET BUILD_TYPE=%CONFIG%
) ELSE (
    SET BUILD_TYPE=Release
)

CALL "C:\BuildTools\Common7\Tools\VsDevCmd.bat" &&
cmake -S . -B build -G "Visual Studio 16 2019" -A x64 &&
cmake --build build --config %BUILD_TYPE%
