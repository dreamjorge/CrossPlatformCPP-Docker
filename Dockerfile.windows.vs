# escape=`

# Use Base Image
FROM crossplatformapp-windows-base AS vs_build

# Build Arguments
ARG VS_YEAR=2019
ARG VS_VERSION=16
ARG CHANNEL_URL=https://aka.ms/vs/${VS_VERSION}/release/channel
ARG VS_BUILD_TOOLS_URL=https://aka.ms/vs/${VS_VERSION}/release/vs_buildtools.exe
ARG CMAKE_VERSION=3.21.3

# Environment Variables
ENV VS_YEAR=${VS_YEAR}
ENV VS_VERSION=${VS_VERSION}
ENV CMAKE_VERSION=${CMAKE_VERSION}
ENV CHANNEL_URL=${CHANNEL_URL}
ENV VS_BUILD_TOOLS_URL=${VS_BUILD_TOOLS_URL}

# Copy Installation Scripts
COPY scripts/windows/install_vs_buildtools.ps1 C:\scripts\install_vs_buildtools.ps1
COPY scripts/windows/install_cmake_bypass.ps1 C:\scripts\install_cmake_bypass.ps1
COPY scripts/windows/build.ps1 C:/app/scripts/windows/build.ps1
COPY scripts/windows/run.ps1 C:/app/scripts/windows/run.ps1

# Debugging: Verify Environment Variables
RUN echo "CHANNEL_URL=$CHANNEL_URL" && echo "VS_BUILD_TOOLS_URL=$VS_BUILD_TOOLS_URL"

# Install Visual Studio Build Tools
RUN powershell -NoProfile -ExecutionPolicy Bypass -Command `
    Write-Host "Installing Visual Studio Build Tools..."; `
    powershell -File "C:\\scripts\\install_vs_buildtools.ps1" -VsVersion $Env:VS_VERSION

# Install CMake using the PowerShell script
RUN powershell -NoProfile -ExecutionPolicy Bypass -File "C:\\scripts\\install_cmake_bypass.ps1"

# Validate Installation (msbuild and cl)
RUN powershell -NoProfile -ExecutionPolicy Bypass -Command `
    Write-Host "Validating Visual Studio Build Tools installation..."; `
    # Ensure vswhere.exe is available
    $vswherePath = "C:\temp\vswhere.exe"; `
    if (-not (Test-Path $vswherePath)) { `
        Write-Host "vswhere.exe not found. Downloading..."; `
        Invoke-WebRequest -Uri "https://github.com/microsoft/vswhere/releases/latest/download/vswhere.exe" -OutFile $vswherePath `
    }; `
    # Find msbuild.exe
    $msbuildPath = & $vswherePath -latest -products * -requires Microsoft.VisualStudio.Component.MSBuild -find MSBuild\**\Bin\msbuild.exe; `
    # Find cl.exe
    $clPath = & $vswherePath -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -find VC\Tools\MSVC\**\bin\Hostx64\x64\cl.exe; `
    if ($msbuildPath) { `
        Write-Host "msbuild.exe found at $msbuildPath"; `
        $msbuildDir = Split-Path $msbuildPath; `
        $env:PATH += ";$msbuildDir"; `
    } else { `
        Write-Error "msbuild.exe not found."; 
    }; `
    if ($clPath) { `
        Write-Host "cl.exe found at $clPath"; `
        $clDir = Split-Path $clPath; `
        $env:PATH += ";$clDir"; `
    } else { `
        Write-Error "cl.exe not found."; 
    }; `
    # Now try Get-Command
    Get-Command msbuild; `
    Get-Command cl; `
    Write-Host "Validation complete."

# Verify CMake Installation
RUN powershell -NoProfile -ExecutionPolicy Bypass -Command `
    Write-Host "Verifying CMake installation..."; `
    cmake --version

# Set Working Directory
WORKDIR C:\app

# Default Command
CMD ["cmd.exe"]