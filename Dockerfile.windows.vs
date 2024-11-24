escape=`

# Base Image
FROM crossplatformapp-windows-base AS vs_build

# Build Arguments
ARG VS_YEAR=2019
ARG VS_VERSION=16
ARG CMAKE_VERSION=3.21.3

# Environment Variables
ENV VS_YEAR=${VS_YEAR} `
    VS_VERSION=${VS_VERSION} `
    CMAKE_VERSION=${CMAKE_VERSION}

# Copy Scripts
COPY scripts/windows/install_vs_buildtools.ps1 C:\scripts\install_vs_buildtools.ps1
COPY scripts/windows/install_cmake_bypass.ps1 C:\scripts\install_cmake_bypass.ps1
COPY scripts/windows/build.ps1 C:\app\scripts\windows\build.ps1
COPY scripts/windows/run.ps1 C:\app\scripts\windows\run.ps1

# Debug: Verify Arguments and Environment Variables
RUN powershell -Command `
    Write-Host "VS_VERSION is $env:VS_VERSION"; `
    Write-Host "VS_YEAR is $env:VS_YEAR"; `
    Write-Host "CMAKE_VERSION is $env:CMAKE_VERSION"

# Install Visual Studio Build Tools
RUN powershell -NoProfile -ExecutionPolicy Bypass -File "C:\scripts\install_vs_buildtools.ps1"

# Install CMake
RUN powershell -NoProfile -ExecutionPolicy Bypass -File "C:\scripts\install_cmake_bypass.ps1"

# Detect MSVC Version and Set Environment Variable
RUN powershell -Command `
    $msvcDirs = Get-ChildItem -Directory "C:\Program Files (x86)\Microsoft Visual Studio\$env:VS_YEAR\BuildTools\VC\Tools\MSVC"; `
    if ($msvcDirs.Count -gt 0) { `
        $msvcVersion = $msvcDirs[0].Name; `
        Write-Host "Detected MSVC Version: $msvcVersion"; `
        [System.Environment]::SetEnvironmentVariable('MSVC_VERSION', $msvcVersion, 'Machine'); `
        Write-Host "MSVC_VERSION=$msvcVersion" >> C:\msvc_version.env; `
    } else { `
        throw "MSVC directory not found."; `
    }

# Update PATH for MSVC and CMake
RUN powershell -Command `
    $envPath = "C:\\cmake\\bin;C:\\Program Files (x86)\\Microsoft Visual Studio\\$env:VS_YEAR\\BuildTools\\MSBuild\\Current\\Bin;C:\\Program Files (x86)\\Microsoft Visual Studio\\$env:VS_YEAR\\BuildTools\\VC\\Tools\\MSVC\\$env:MSVC_VERSION\\bin\\Hostx64\\x64;$env:Path"; `
    Write-Host "Updating PATH with MSVC and CMake"; `
    [Environment]::SetEnvironmentVariable('PATH', $envPath, 'Machine')

# Verify Installation
RUN powershell -Command `
    cmake --version; `
    cl.exe /?; `
    msbuild.exe /version

# Set Working Directory
WORKDIR C:\app

# Debugging Info for Final Image
RUN powershell -Command `
    Write-Host "Final PATH: $env:Path"; `
    Write-Host "MSVC_VERSION: $env:MSVC_VERSION"

# Default Command
CMD ["cmd.exe"]