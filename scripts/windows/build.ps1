<#
.SYNOPSIS
  Builds the application using CMake and Visual Studio Build Tools.

.DESCRIPTION
  This script initializes the Visual Studio environment, configures the project with CMake, and builds it.

.PARAMETER CONFIG
  The build configuration, e.g., Debug or Release.

.PARAMETER VS_VERSION
  The version of Visual Studio to use, e.g., 15 (2017), 16 (2019), or 17 (2022).

.NOTES
  - If APP_WORKDIR is not set, the script assumes the repository root is the parent directory of the script.
  - The script logs output to build.log in the APP_WORKDIR directory.

.EXAMPLE
  .\build.ps1 -CONFIG Release -VS_VERSION 17
#>

Param (
    [string]$CONFIG,
    [string]$VS_VERSION
)

# --- Configuration Parameters ---
# Centralized at the top for easy modification
$ErrorActionPreference = 'Stop'

# --- Function Definitions ---

function Initialize-AppWorkDir {
    <#
    .SYNOPSIS
      Initializes the APP_WORKDIR environment variable.

    .DESCRIPTION
      If APP_WORKDIR is not set, determines the repository root based on the script's location.

    .OUTPUTS
      Sets the $env:APP_WORKDIR variable.
    #>
    if (-not $env:APP_WORKDIR) {
        # Get the directory of the script
        $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
        # Assume the root of the repository is the parent directory of the script directory
        $env:APP_WORKDIR = Split-Path -Parent $scriptDir
        Write-Host "APP_WORKDIR not set. Using repository root: $env:APP_WORKDIR"
    } else {
        Write-Host "APP_WORKDIR is set to: $env:APP_WORKDIR"
    }
}

function Get-VsDevCmdPath {
    <#
    .SYNOPSIS
      Retrieves the path to VsDevCmd.bat based on the Visual Studio version.

    .PARAMETER vsVersion
      The Visual Studio version number.

    .OUTPUTS
      Returns the path to VsDevCmd.bat if found; otherwise, returns $null.
    #>
    param([string]$vsVersion)

    # Check for BuildTools path (Docker image)
    $buildToolsPath = "C:\BuildTools\Common7\Tools\VsDevCmd.bat"
    if (Test-Path $buildToolsPath) {
        return $buildToolsPath
    }

    # Determine VS year based on version number
    switch ($vsVersion) {
        "15" { $vsYear = "2017" }
        "16" { $vsYear = "2019" }
        "17" { $vsYear = "2022" }
        default {
            $errorMsg = "ERROR: Unsupported VS_VERSION=$vsVersion"
            Write-Host $errorMsg
            exit 1
        }
    }

    # Possible editions of Visual Studio
    $vsEditions = @("BuildTools", "Community", "Professional", "Enterprise")

    # Possible Program Files directories
    $programFilesDirs = @(
        "${env:ProgramFiles(x86)}",
        "${env:ProgramFiles}"
    )

    foreach ($programFiles in $programFilesDirs) {
        foreach ($edition in $vsEditions) {
            $vsDevCmdCandidate = Join-Path -Path $programFiles -ChildPath "Microsoft Visual Studio\$vsYear\$edition\Common7\Tools\VsDevCmd.bat"
            if (Test-Path $vsDevCmdCandidate) {
                return $vsDevCmdCandidate
            }
        }
    }

    # If not found, return null
    return $null
}

function Initialize-VisualStudioEnvironment {
    <#
    .SYNOPSIS
      Initializes the Visual Studio build environment.

    .PARAMETER vsDevCmdPath
      The path to VsDevCmd.bat.

    .OUTPUTS
      Initializes the environment variables for Visual Studio.
    #>
    param([string]$vsDevCmdPath)

    Write-Host "Initializing Visual Studio environment with $vsDevCmdPath"
    & "$vsDevCmdPath" | Out-Null
    if ($LASTEXITCODE -ne 0) {
        $errorMsg = "ERROR: Failed to initialize Visual Studio environment"
        Write-Host $errorMsg
        exit 1
    }
}

function Validate-CMakeInstallation {
    <#
    .SYNOPSIS
      Validates that CMake is installed and accessible.

    .OUTPUTS
      Verifies that CMake can be invoked.
    #>
    Write-Host "Validating CMake installation..."
    cmake --version | Out-Null
    if ($LASTEXITCODE -ne 0) {
        $errorMsg = "ERROR: CMake is not installed or not in PATH!"
        Write-Host $errorMsg
        exit 1
    }
}

function Run-CMakeConfiguration {
    <#
    .SYNOPSIS
      Configures the project using CMake.

    .PARAMETER sourceDir
      The source directory.

    .PARAMETER buildDir
      The build directory.

    .PARAMETER config
      The build configuration.

    .OUTPUTS
      Runs the CMake configuration step.
    #>
    param(
        [string]$sourceDir,
        [string]$buildDir,
        [string]$config
    )

    Write-Host "Running CMake configuration..."
    cmake -S $sourceDir -B $buildDir -DCMAKE_BUILD_TYPE=$config
    if ($LASTEXITCODE -ne 0) {
        $errorMsg = "ERROR: CMake configuration failed"
        Write-Host $errorMsg
        exit 1
    }
}

function Build-Project {
    <#
    .SYNOPSIS
      Builds the project using CMake.

    .PARAMETER buildDir
      The build directory.

    .PARAMETER config
      The build configuration.

    .OUTPUTS
      Builds the project.
    #>
    param(
        [string]$buildDir,
        [string]$config
    )

    Write-Host "Building project..."
    cmake --build $buildDir --config $config
    if ($LASTEXITCODE -ne 0) {
        $errorMsg = "ERROR: Build failed"
        Write-Host $errorMsg
        exit 1
    }
}

# --- Main Script Execution ---

# Initialize APP_WORKDIR
Initialize-AppWorkDir

# Initialize logging
$LOG_FILE = "$env:APP_WORKDIR\build.log"
Write-Host "Starting build process at $(Get-Date)"
Write-Host "Logging to $LOG_FILE"
"Starting build process at $(Get-Date)" | Out-File $LOG_FILE
"Logging to $LOG_FILE" | Out-File $LOG_FILE -Append

# Use CONFIG and VS_VERSION from environment variables if parameters are not provided
if (-not $CONFIG) {
    $CONFIG = $env:CONFIG
}
if (-not $VS_VERSION) {
    $VS_VERSION = $env:VS_VERSION
}

# Validate parameters
if (-not $CONFIG) {
    $errorMsg = "ERROR: Missing CONFIG parameter (Debug/Release)"
    Write-Host $errorMsg
    $errorMsg | Out-File $LOG_FILE -Append
    exit 1
}
if (-not $VS_VERSION) {
    $errorMsg = "ERROR: Missing VS_VERSION parameter (15/16/17)"
    Write-Host $errorMsg
    $errorMsg | Out-File $LOG_FILE -Append
    exit 1
}

Write-Host "Using CONFIG=$CONFIG and VS_VERSION=$VS_VERSION"
"Using CONFIG=$CONFIG and VS_VERSION=$VS_VERSION" | Out-File $LOG_FILE -Append

# Get the path to VsDevCmd.bat
$vsDevCmd = Get-VsDevCmdPath -vsVersion $VS_VERSION

if (-not $vsDevCmd) {
    $errorMsg = "ERROR: Could not find VsDevCmd.bat for VS_VERSION=$VS_VERSION"
    Write-Host $errorMsg
    $errorMsg | Out-File $LOG_FILE -Append
    exit 1
}

# Initialize Visual Studio environment
Initialize-VisualStudioEnvironment -vsDevCmdPath $vsDevCmd

# Validate CMake installation
Validate-CMakeInstallation

# Run CMake configuration
Run-CMakeConfiguration -sourceDir $env:APP_WORKDIR -buildDir "$env:APP_WORKDIR\build" -config $CONFIG

# Build the project
Build-Project -buildDir "$env:APP_WORKDIR\build" -config $CONFIG

# Success
Write-Host "Build completed successfully at $(Get-Date)"
"Build completed successfully at $(Get-Date)" | Out-File $LOG_FILE -Append
exit 0
