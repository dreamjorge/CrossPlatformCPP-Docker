param (
    [Parameter(Mandatory=$true)]
    [string]$VS_YEAR
)

# Exit immediately if an error occurs
$ErrorActionPreference = "Stop"

Write-Host "INFO: Running script to set VS_VERSION based on VS_YEAR: $VS_YEAR"

# Determine VS_VERSION based on VS_YEAR
switch ($VS_YEAR) {
    "2017" {
        $VS_VERSION = "15"
        Write-Host "INFO: Detected VS_YEAR=2017, setting VS_VERSION=15"
    }
    "2019" {
        $VS_VERSION = "16"
        Write-Host "INFO: Detected VS_YEAR=2019, setting VS_VERSION=16"
    }
    "2022" {
        $VS_VERSION = "17"
        Write-Host "INFO: Detected VS_YEAR=2022, setting VS_VERSION=17"
    }
    default {
        Write-Error "ERROR: Unsupported VS_YEAR: $VS_YEAR"
        exit 1
    }
}

# Export VS_VERSION to GitHub Actions environment
if ($env:GITHUB_ENV) {
    Write-Host "INFO: Exporting VS_VERSION=$VS_VERSION to GitHub Actions environment"
    "VS_VERSION=$VS_VERSION" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
} else {
    Write-Host "WARNING: GITHUB_ENV is not set. VS_VERSION is not exported."
}

# Optional: Output the VS_VERSION for verification
Write-Host "INFO: VS_VERSION is set to $VS_VERSION"
