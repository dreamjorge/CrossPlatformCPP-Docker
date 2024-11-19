# escape=`

# ===================================================================
# Build Image
# ===================================================================
# This Dockerfile uses the base image defined in the previous stage and
# adds the necessary tools, such as CMake, for building applications. By
# separating the build-specific tools into this Dockerfile, we can reduce
# redundancy and maintain a lightweight base image.
FROM base AS vs_build

# ===================================================================
# Build Arguments
# ===================================================================
# These arguments are used to specify the URLs for downloading the Visual Studio
# Build Tools and the CMake version to be installed. They can be overridden at build time.
ARG VS_YEAR=2022
ARG VS_VERSION=17
ARG CMAKE_VERSION=3.21.3

# ===================================================================
# Environment Variables
# ===================================================================
# Environment variables are used to define paths and directories for the build process.
ENV VS_YEAR=${VS_YEAR}
ENV VS_VERSION=${VS_VERSION}
ENV CMAKE_VERSION=${CMAKE_VERSION}

# ===================================================================
# Set Shell to cmd
# ===================================================================
# The default shell for running commands is set to cmd.exe. This ensures that
# all subsequent commands are executed in the context of the Windows command prompt.
SHELL ["cmd", "/S", "/C"]

# ===================================================================
# Copy Installation Scripts
# ===================================================================
# The installation scripts for installing Chocolatey and CMake are copied into the image.
COPY scripts/windows/install_choco_cmake.ps1 C:\scripts\install_choco_cmake.ps1

# ===================================================================
# Install Chocolatey Package Manager and CMake
# ===================================================================
# This step runs a PowerShell script to install Chocolatey and the specified version of CMake.
# Chocolatey is a package manager for Windows, and CMake is a build system generator.
RUN powershell -NoProfile -ExecutionPolicy Bypass -File C:\scripts\install_choco_cmake.ps1

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
