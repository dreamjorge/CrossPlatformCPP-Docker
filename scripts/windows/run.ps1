<#
.SYNOPSIS
  Runs the built application.

.DESCRIPTION
  This script executes the compiled application based on the specified configuration.

.PARAMETER CONFIG
  The build configuration, e.g., Debug or Release.

.NOTES
  - If APP_WORKDIR is not set, the script assumes the repository root is the parent directory of the script.

.EXAMPLE
  .\run.ps1 -CONFIG Release
#>

Param (
    [string]$CONFIG
)

# --- Configuration Parameters ---
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

function Execute-Application {
    <#
    .SYNOPSIS
      Executes the built application.

    .PARAMETER execPath
      The path to the executable.

    .OUTPUTS
      Runs the application and handles the exit code.
    #>
    param([string]$execPath)

    Write-Host "Executing: $execPath"
    & "$execPath"
    $exitCode = $LASTEXITCODE

    # Handle the exit code
    if ($exitCode -ne 0) {
        Write-Host "ERROR: Application execution failed with exit code $exitCode."
        exit $exitCode
    } else {
        Write-Host "Application executed successfully."
    }
}

# --- Main Script Execution ---

# Initialize APP_WORKDIR
Initialize-AppWorkDir

# Use CONFIG from environment variable if parameter is not provided
if (-not $CONFIG) {
    $CONFIG = $env:CONFIG
}

if (-not $CONFIG) {
    Write-Host "ERROR: Missing CONFIG parameter (Debug/Release)"
    exit 1
}

Write-Host "Running application in $CONFIG mode."

# Determine BUILD_TYPE based on CONFIG
$BUILD_TYPE = $CONFIG

Write-Host "BUILD_TYPE is $BUILD_TYPE"

# Specify the absolute path to the executable based on the build type
$EXEC_PATH = "$env:APP_WORKDIR\build\$BUILD_TYPE\CrossPlatformApp.exe"

if (-not (Test-Path $EXEC_PATH)) {
    Write-Host "ERROR: Executable not found at $EXEC_PATH"
    exit 1
}

# Execute the application
Execute-Application -execPath $EXEC_PATH
