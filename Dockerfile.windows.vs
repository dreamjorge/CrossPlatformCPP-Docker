# escape=`

# Use Base Image
FROM base AS vs_build

# Build Arguments
ARG VS_YEAR=2022
ARG VS_VERSION=17
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

# Debugging: Verify Environment Variables
RUN echo "CHANNEL_URL=$CHANNEL_URL" && echo "VS_BUILD_TOOLS_URL=$VS_BUILD_TOOLS_URL"

# Install Visual Studio Build Tools
RUN powershell -NoProfile -ExecutionPolicy Bypass -File "C:\\scripts\\install_vs_buildtools.ps1"

# Install CMake
RUN powershell -NoProfile -ExecutionPolicy Bypass -Command `
    "$cmakeVersion = (cmake --version 2>$null | Select-String -Pattern '^cmake version (\d+\.\d+\.\d+)' | ForEach-Object { $_.Matches.Groups[1].Value }); `
    if ($cmakeVersion -ne '${CMAKE_VERSION}') { `
        Write-Host 'Installing CMake ${CMAKE_VERSION}...'; `
        choco install cmake --version=${CMAKE_VERSION} --installargs 'ADD_CMAKE_TO_PATH=System' -y; `
    } else { `
        Write-Host 'CMake ${CMAKE_VERSION} is already installed.'; `
    }"

# Set Working Directory
WORKDIR C:\app

# Default Command
CMD ["cmd.exe"]