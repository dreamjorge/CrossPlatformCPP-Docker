Param (
    [string]$CONFIG
)

# Determine the root of the repository
if (-not $env:APP_WORKDIR) {
    # Check if C:\app exists (Docker environment)
    if (Test-Path "C:\app") {
        $env:APP_WORKDIR = "C:\app"
        Write-Host "APP_WORKDIR not set. Using Docker app directory: $env:APP_WORKDIR"
    } else {
        # Get the directory of the script
        $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
        # Assume the root of the repository is the parent directory of the script directory
        $env:APP_WORKDIR = Split-Path -Parent $scriptDir
        Write-Host "APP_WORKDIR not set. Using repository root: $env:APP_WORKDIR"
    }
}

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

Write-Host "Executing: $EXEC_PATH"

# Execute the application
& "$EXEC_PATH"
$exitCode = $LASTEXITCODE

# Handle the exit code
if ($exitCode -ne 0) {
    Write-Host "ERROR: Application execution failed with exit code $exitCode."
    exit $exitCode
} else {
    Write-Host "Application executed successfully."
}
