# escape=`

# ===================================================================
# Base Image
# ===================================================================
# This Dockerfile uses a multi-stage build approach. The first stage is the base image,
# which contains common setup steps that are shared across multiple Dockerfiles.
# By using a base image, we can reduce redundancy, improve maintainability, and ensure
# consistency across different Dockerfiles for various Visual Studio versions.
FROM base AS vs_build

# ===================================================================
# Build Arguments
# ===================================================================
# These arguments are used to specify the URLs for downloading the Visual Studio
# Build Tools and the CMake version to be installed. They can be overridden at build time.
ARG VS_YEAR=2022
ARG VS_VERSION=17
ARG CHANNEL_URL=https://aka.ms/vs/${VS_VERSION}/release/channel
ARG VS_BUILD_TOOLS_URL=https://aka.ms/vs/${VS_VERSION}/release/vs_buildtools.exe
ARG CMAKE_VERSION=3.21.3

# ===================================================================
# Environment Variables
# ===================================================================
# Set environment variables based on build arguments
ENV VS_YEAR=${VS_YEAR}
ENV VS_VERSION=${VS_VERSION}
ENV CMAKE_VERSION=${CMAKE_VERSION}


# ===================================================================
# Install Visual Studio Build Tools with C++ Workload
# ===================================================================
# This step runs a PowerShell script to install the Visual Studio Build Tools with
# the C++ workload. The script uses the build arguments to download and install
# the necessary components.
RUN powershell -NoProfile -ExecutionPolicy Bypass -File C:\scripts\install_vs_buildtools.ps1

# ===================================================================
# Set Working Directory
# ===================================================================
# The working directory is set to C:\app, where the application code will be copied
# and built. This ensures that all subsequent commands are run in the context of
# this directory.
WORKDIR C:\app

# ===================================================================
# Default Command
# ===================================================================
# The default command to run when the container starts. In this case, it starts
# a command prompt (cmd.exe) to allow for interactive use or further commands.
CMD ["cmd.exe"]