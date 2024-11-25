# escape=`

# ===================================================================
# Base Image
# ===================================================================
FROM mcr.microsoft.com/windows/servercore:ltsc2022 AS base

# ===================================================================
# Stage: Visual Studio 2019 Build Environment
# ===================================================================
FROM base AS vs19

# ===================================================================
# Build Arguments
# ===================================================================
# These arguments specify Visual Studio and CMake versions,
# as well as the URLs for downloading necessary tools.
ARG VS_YEAR=2019
ARG VS_VERSION=16
ARG CMAKE_VERSION=3.21.3

# ===================================================================
# Environment Variables
# ===================================================================
# Set environment variables for consistent setup.
ENV VS_YEAR=${VS_YEAR} `
    VS_VERSION=${VS_VERSION} `
    CMAKE_VERSION=${CMAKE_VERSION} `
    VS_BUILDTOOLS_PATH="C:\\BuildTools" `
    TEMP_DIR="C:\\TEMP"

# ===================================================================
# Switch to PowerShell for subsequent RUN commands
# ===================================================================
SHELL ["powershell", "-NoProfile", "-Command"]

# ===================================================================
# Create TEMP directory
# ===================================================================
RUN if (-not (Test-Path -Path $env:TEMP_DIR)) { `
        New-Item -ItemType Directory -Path $env:TEMP_DIR | Out-Null `
    }

# ===================================================================
# Debugging: Verify Environment Variables
# ===================================================================
# Output environment variables for debugging and validation.
RUN Write-Host "VS_VERSION: $env:VS_VERSION"; `
    Write-Host "VS_BUILD_TOOLS_URL: https://aka.ms/vs/$env:VS_VERSION/release/vs_buildtools.exe"; `
    Write-Host "CMAKE_VERSION: $env:CMAKE_VERSION"; `
    Write-Host "VS_BUILDTOOLS_PATH: $env:VS_BUILDTOOLS_PATH"; `
    Write-Host "TEMP_DIR: $env:TEMP_DIR"

# ===================================================================
# Download Visual Studio Build Tools Installer
# ===================================================================
RUN Write-Host "Downloading Visual Studio Build Tools from https://aka.ms/vs/$env:VS_VERSION/release/vs_buildtools.exe"; `
    $vsBuildToolsUrl = "https://aka.ms/vs/$env:VS_VERSION/release/vs_buildtools.exe"; `
    $installerPath = "$env:TEMP_DIR\\vs_buildtools.exe"; `
    try { `
        Invoke-WebRequest -Uri $vsBuildToolsUrl -OutFile $installerPath -UseBasicParsing -ErrorAction Stop `
    } catch { `
        throw "Failed to download Visual Studio Build Tools installer: $_" `
    }

# ===================================================================
# Verify Installer Download
# ===================================================================
RUN $installerSize = (Get-Item "$env:TEMP_DIR\\vs_buildtools.exe").Length; `
    if ($installerSize -lt 1MB) { `
        throw "Downloaded Visual Studio Build Tools installer is too small ($installerSize bytes). Download may have failed." `
    } else { `
        Write-Host "Visual Studio Build Tools installer downloaded successfully! File size: $([Math]::Round($installerSize / 1MB, 2)) MB" `
    }

# ===================================================================
# Install Visual Studio Build Tools with C++ Workload
# ===================================================================
RUN Write-Host "Installing Visual Studio Build Tools..."; `
    $installArgs = @(`
        '--quiet', `
        '--wait', `
        '--norestart', `
        '--nocache', `
        '--installPath', "`"$env:VS_BUILDTOOLS_PATH`"", `
        '--add', 'Microsoft.VisualStudio.Workload.VCTools', `
        '--includeRecommended', `
        '--lang', 'en-US', `
        '--log', "$env:TEMP_DIR\\vs_buildtools_install.log"`
    ); `
    $process = Start-Process -FilePath "$env:TEMP_DIR\\vs_buildtools.exe" -ArgumentList $installArgs -NoNewWindow -Wait -PassThru; `
    switch ($process.ExitCode) { `
        0 { Write-Host "Visual Studio Build Tools installed successfully." } `
        3010 { `
            Write-Host "Visual Studio Build Tools installation completed with exit code 3010 (restart required). Continuing without restart..." `
        } `
        default { `
            Write-Host "Visual Studio Build Tools installer failed with exit code $($process.ExitCode)."; `
            Write-Host "Installer log contents:"; `
            Get-Content "$env:TEMP_DIR\\vs_buildtools_install.log" | Write-Host; `
            throw "Visual Studio Build Tools installation failed. Check the log at $env:TEMP_DIR\\vs_buildtools_install.log" `
        } `
    }

# ===================================================================
# Clean Up Visual Studio Build Tools Installer and Log
# ===================================================================
RUN Remove-Item -Path "$env:TEMP_DIR\\vs_buildtools.exe" -Force; `
    Remove-Item -Path "$env:TEMP_DIR\\vs_buildtools_install.log" -Force

# ===================================================================
# Download and Install CMake
# ===================================================================
RUN Write-Host "Downloading CMake version $env:CMAKE_VERSION..."; `
    $cmakeUrl = "https://github.com/Kitware/CMake/releases/download/v$env:CMAKE_VERSION/cmake-$env:CMAKE_VERSION-windows-x86_64.msi"; `
    $cmakeInstaller = "$env:TEMP_DIR\\cmake.msi"; `
    try { `
        Invoke-WebRequest -Uri $cmakeUrl -OutFile $cmakeInstaller -UseBasicParsing -ErrorAction Stop `
    } catch { `
        throw "Failed to download CMake installer: $_" `
    }

# ===================================================================
# Verify CMake Installer Download
# ===================================================================
RUN $cmakeInstallerSize = (Get-Item "$env:TEMP_DIR\\cmake.msi").Length; `
    if ($cmakeInstallerSize -lt 500KB) { `
        throw "Downloaded CMake installer is too small ($cmakeInstallerSize bytes). Download may have failed." `
    } else { `
        Write-Host "CMake installer downloaded successfully! File size: $([Math]::Round($cmakeInstallerSize / 1MB, 2)) MB" `
    }

# ===================================================================
# Install CMake Silently
# ===================================================================
RUN Write-Host "Installing CMake..."; `
    Start-Process msiexec.exe -ArgumentList "/i `"$cmakeInstaller`" /quiet /qn /norestart" -Wait; `
    # Add CMake to system PATH
    $cmakePath = "C:\\Program Files\\CMake\\bin"; `
    Write-Host "Adding CMake to system PATH..."; `
    [Environment]::SetEnvironmentVariable("Path", "$env:Path;$cmakePath", "Machine"); `
    # Verify CMake installation
    Write-Host "Verifying CMake installation..."; `
    cmake --version; `
    # Clean Up CMake Installer
    Remove-Item -Path "$cmakeInstaller" -Force

# ===================================================================
# Verify Visual Studio Build Tools Installation
# ===================================================================
RUN Write-Host "Verifying Visual Studio Build Tools installation..."; `
    $vswherePath = "$env:VS_BUILDTOOLS_PATH\\Common7\\Tools\\vswhere.exe"; `
    if (-Not (Test-Path $vswherePath)) { `
        throw "vswhere.exe not found at $vswherePath. Visual Studio Build Tools may not be installed correctly." `
    } else { `
        $installationPath = & $vswherePath -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath; `
        if ([string]::IsNullOrEmpty($installationPath)) { `
            throw "Visual Studio Build Tools installation not found by vswhere.exe." `
        } else { `
            Write-Host "Visual Studio Build Tools installed at: $installationPath" `
        } `
    }

# ===================================================================
# Set Working Directory
# ===================================================================
WORKDIR C:\\app

# ===================================================================
# Default Command
# ===================================================================
CMD ["powershell.exe"]