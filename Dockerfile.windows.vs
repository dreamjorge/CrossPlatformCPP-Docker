# escape=`

FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2022 AS base

LABEL maintainer="your-email@example.com" `
      description="Docker image for building and running CrossPlatformApp using Visual Studio Build Tools" `
      version="1.0.0" `
      repository="https://github.com/your-repo/CrossPlatformCPP-Docker" `
      documentation="https://github.com/your-repo/CrossPlatformCPP-Docker#readme" `
      issues="https://github.com/your-repo/CrossPlatformCPP-Docker/issues" `
      license="MIT"

ARG VS_VERSION=16  # Use 16 for VS2019, 17 for VS2022, etc.
ARG VS_YEAR=2019

ENV BUILD_TOOLS_PATH=C:\BuildTools `
    TEMP_DIR=C:\TEMP `
    LOG_PATH=C:\TEMP\vs_buildtools_install.log `
    VS_VERSION=${VS_VERSION} `
    VS_YEAR=${VS_YEAR}

# Set shell to PowerShell
SHELL ["powershell.exe", "-NoProfile", "-Command", "$ErrorActionPreference = 'Stop';"]

# Create TEMP directory
RUN New-Item -Path $env:TEMP_DIR -ItemType Directory -Force

# Download installer
RUN Write-Host "Downloading Visual Studio Build Tools installer..." `
    ; Invoke-WebRequest -Uri "https://aka.ms/vs/$env:VS_VERSION/release/vs_buildtools.exe" -OutFile "$env:TEMP_DIR\vs_buildtools.exe" `
    ; Write-Host "Downloaded Visual Studio Build Tools installer successfully."

# Install Build Tools
RUN Write-Host "Installing Visual Studio Build Tools..." `
    ; & "$env:TEMP_DIR\vs_buildtools.exe" `
        "--quiet --wait --norestart --nocache --installPath C:\BuildTools --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended --log C:\TEMP\vs_buildtools_install.log" `
    ; Write-Host "Visual Studio Build Tools installation completed."

# Verify installation
RUN Write-Host "Verifying Visual Studio Build Tools installation..." `
    ; $clPathPattern = "$env:BUILD_TOOLS_PATH\VC\Tools\MSVC\*\bin\Hostx64\x64\cl.exe" `
    ; $clExists = Get-ChildItem -Path $clPathPattern -ErrorAction SilentlyContinue | Select-Object -First 1 `
    ; if ($clExists) { `
        Write-Host "Verification successful: cl.exe found at $($clExists.FullName)." `
    } else { `
        Write-Host "Verification failed: cl.exe not found. Installation may have failed." `
        exit 1 `
    }

# Output installation logs (optional)
RUN if (Test-Path "C:\\TEMP\\vs_buildtools_install.log") { `
        Get-Content "C:\\TEMP\\vs_buildtools_install.log" `
    }

# Clean up installer
RUN Write-Host "Cleaning up temporary files..." `
    ; Remove-Item -Path "$env:TEMP_DIR\vs_buildtools.exe" -Force `
    ; Write-Host "Temporary files removed successfully."

WORKDIR C:\app

CMD ["cmd.exe"]