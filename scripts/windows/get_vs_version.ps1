param (
    [Parameter(Mandatory = $true)]
    [string]$VS_YEAR
)

# Exit immediately if an error occurs
$ErrorActionPreference = "Stop"

Write-Host "INFO: Determining VS_VERSION for VS_YEAR: $VS_YEAR"

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

# Output the VS_VERSION
Write-Output $VS_VERSION
