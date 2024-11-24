# escape=`

# Use the latest Windows Server Core image
FROM mcr.microsoft.com/windows/servercore:ltsc2022 AS vs_build

# Build Arguments
ARG VS_YEAR=2022
ARG VS_VERSION=17
ARG CMAKE_VERSION=3.21.3

# Environment Variables
ENV VS_YEAR=${VS_YEAR} `
    VS_VERSION=${VS_VERSION} `
    CMAKE_VERSION=${CMAKE_VERSION}

# Copy Scripts
COPY scripts/windows/install_vs_buildtools.ps1 C:/scripts/install_vs_buildtools.ps1
COPY scripts/windows/install_cmake_bypass.ps1 C:/scripts/install_cmake_bypass.ps1
COPY scripts/windows/build.ps1 C:/app/scripts/windows/build.ps1
COPY scripts/windows/run.ps1 C:/app/scripts/windows/run.ps1

# Install Visual Studio Build Tools and CMake
RUN powershell -NoProfile -ExecutionPolicy Bypass -Command `
    & "C:\\scripts\\install_vs_buildtools.ps1" `
        -VS_YEAR $env:VS_YEAR `
        -VS_VERSION $env:VS_VERSION `
    ; `
    & "C:\\scripts\\install_cmake_bypass.ps1" `
        -CMAKE_VERSION $env:CMAKE_VERSION

# Set Working Directory
WORKDIR C:/app

# Default Command
CMD ["cmd.exe"]