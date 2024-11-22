param (
    [Parameter(Mandatory = $true)]
    [string]$Config,
    [Parameter(Mandatory = $true)]
    [string]$BuildDir
)

# Exit immediately if an error occurs
$ErrorActionPreference = "Stop"

Write-Host "INFO: Starting application with configuration: $Config"

# Construct the path to the executable
$exePath = Join-Path -Path $BuildDir -ChildPath "bin\$Config\CrossPlatformApp.exe"

# Verify executable exists
if (-not (Test-Path $exePath)) {
    Write-Error "ERROR: Executable not found at $exePath"
    exit 1
}

# Run the executable
Write-Host "INFO: Running executable at $exePath"
& $exePath

Write-Host "INFO: Application execution completed successfully."
