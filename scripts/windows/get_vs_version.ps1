param (
    [Parameter(Mandatory=$true)]
    [string]$VS_YEAR
)

# Exit immediately if an error occurs
$ErrorActionPreference = "Stop"

Write-Host "INFO: Determining VS_VERSION for VS_YEAR: $VS_YEAR"

# Determine VS_VERSION based on VS_YEAR
switch ($VS_YEAR) {
    "2017" {
        Write-Output "15"
    }
    "2019" {
        Write-Output "16"
    }
    "2022" {
        Write-Output "17"
    }
    default {
        Write-Error "ERROR: Unsupported VS_YEAR: $VS_YEAR"
        exit 1
    }
}
