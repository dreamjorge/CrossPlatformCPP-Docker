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

# Copy scripts
COPY scripts/windows/install_vs_buildtools.ps1 C:\scripts\install_vs_buildtools.ps1

# Debugging: Verify Environment Variables
RUN echo "CHANNEL_URL=$CHANNEL_URL" && echo "VS_BUILD_TOOLS_URL=$VS_BUILD_TOOLS_URL"

# Install Visual Studio Build Tools
RUN powershell -NoProfile -ExecutionPolicy Bypass -File "C:\\scripts\\install_vs_buildtools.ps1"

# Set Working Directory
WORKDIR C:\app

# Default Command
CMD ["cmd.exe"]