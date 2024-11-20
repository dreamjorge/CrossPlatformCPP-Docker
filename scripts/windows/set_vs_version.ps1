param (
    [string]$VS_YEAR
)

# Exit immediately if an error occurs
$ErrorActionPreference = "Stop"

Write-Host "INFO: Running script to set VS_VERSION based on VS_YEAR"

# Check if VS_YEAR is provided
if (-not $VS_YEAR) {
    Write-Error "ERROR: VS_YEAR parameter is not set."
    exit 1
}

# Determine VS_VERSION based on VS_YEAR
switch ($VS_YEAR) {
    "2017" {
        $env:VS_VERSION = "15"
        Write-Host "INFO: Detected VS_YEAR=2017, setting VS_VERSION=15"
    }
    "2019" {
        $env:VS_VERSION = "16"
        Write-Host "INFO: Detected VS_YEAR=2019, setting VS_VERSION=16"
    }
    "2022" {
        $env:VS_VERSION = "17"
        Write-Host "INFO: Detected VS_YEAR=2022, setting VS_VERSION=17"
    }
    default {
        Write-Error "ERROR: Unsupported VS_YEAR: $VS_YEAR"
        exit 1
    }
}

# Export VS_VERSION to GitHub Actions environment
if ($env:GITHUB_ENV) {
    Write-Host "INFO: Exporting VS_VERSION=$env:VS_VERSION to GitHub Actions environment"
    Write-Host "VS_VERSION=$env:VS_VERSION" | Out-File -Append -FilePath $env:GITHUB_ENV
} else {
    Write-Host "INFO: VS_VERSION=$env:VS_VERSION"
}
