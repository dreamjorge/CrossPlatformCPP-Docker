# Use ` as the escape character for Windows
# This must be the first line in the Dockerfile
# Note: This line is optional in newer Docker versions
# escape=`

# Use the official Windows Server Core as the base image
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Set environment variables
ENV BUILD_TOOLS_PATH "C:\\BuildTools"
ENV TEMP_DIR "C:\\TEMP"

# Create necessary directories
RUN mkdir C:\TEMP `
    && mkdir C:\BuildTools

# Download Visual Studio Build Tools installer
ADD https://aka.ms/vs/16/release/vs_buildtools.exe C:\TEMP\vs_buildtools.exe

# Install Visual Studio Build Tools with required workloads
RUN powershell -NoProfile -ExecutionPolicy Bypass -Command `
    Start-Process -Wait -FilePath C:\TEMP\vs_buildtools.exe -ArgumentList `
        '--quiet', `
        '--wait', `
        '--norestart', `
        '--nocache', `
        '--installPath', 'C:\BuildTools', `
        '--add', 'Microsoft.VisualStudio.Workload.VCTools', `
        '--includeRecommended', `
        '--log', 'C:\TEMP\vs_buildtools_install.log'

# Verify installation by checking for cl.exe
RUN powershell -NoProfile -ExecutionPolicy Bypass -Command `
    if (Test-Path -Path "$env:BUILD_TOOLS_PATH\VC\Tools\MSVC\*\bin\Hostx64\x64\cl.exe") { `
        Write-Host 'Verification successful: cl.exe found.' `
    } else { `
        Write-Host 'Verification failed: cl.exe not found. Installation may have failed.'; `
        Exit 1 `
    }

# Set the working directory
WORKDIR C:\app

# Default command
CMD ["cmd.exe"]