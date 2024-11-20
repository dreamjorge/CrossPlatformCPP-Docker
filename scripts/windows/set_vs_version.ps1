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
        Write-Er
