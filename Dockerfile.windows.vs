# escape=`

# Base Image
FROM crossplatformapp-windows-base AS vs_build

# Build Arguments
ARG VS_YEAR=2017
ARG VS_VERSION=15
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

# Debugging: Verify Environment Variables
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
    try { `
        $msvcDirs = Get-ChildItem -Directory "C:\Program Files (x86)\Microsoft Visual Studio\$env:VS_YEAR\BuildTools\VC\Tools\MSVC" -ErrorAction Stop; `
        if ($msvcDirs.Count -gt 0) { `
            $msvcVersion = $msvcDirs[0].Name; `
            Write-Host "Detected MSVC Version: $msvcVersion"; `
            [System.Environment]::SetEnvironmentVariable('MSVC_VERSION', $msvcVersion, 'Machine'); `
        } else { `
            throw "MSVC directory not found."; `
        } `
    } catch { `
        Write-Host "Error detecting MSVC Version: $_"; `
        throw; `
    }

# Update PATH
ENV PATH="C:\\cmake\\bin;C:\\Program Files (x86)\\Microsoft Visual Studio\\${VS_YEAR}\\BuildTools\\MSBuild\\Current\\Bin;C:\\Program Files (x86)\\Microsoft Visual Studio\\${VS_YEAR}\\BuildTools\\VC\\Tools\\MSVC\\%MSVC_VERSION%\\bin\\Hostx64\\x64;${PATH}"

# Verify Installation
RUN powershell -Command `
    cmake --version; `
    cl.exe /?; `
    msbuild.exe /version

# Set Working Directory
WORKDIR C:\app

# Default Command
CMD ["cmd.exe"]