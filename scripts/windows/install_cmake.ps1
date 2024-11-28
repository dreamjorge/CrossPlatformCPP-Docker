param (
    [string]$CMAKE_VERSION = "3.27.1"
)

# Set variables
$retryCount = 0
$maxRetries = 5
$cmakeBaseUrl = "https://github.com/Kitware/CMake/releases/download"
$url = "$cmakeBaseUrl/v$CMAKE_VERSION/cmake-$CMAKE_VERSION-windows-x86_64.zip"
$destination = "C:\TEMP\cmake.zip"
$installPath = "C:\Program Files\CMake"

# Function to download file with retries
function Download-File {
    param (
        [string]$url,
        [string]$outputPath
    )
    do {
        try {
            $retryCount++
            Write-Host "Attempt $($retryCount): Downloading CMake from $url..."
            Invoke-WebRequest -Uri $url -OutFile $outputPath -UseBasicParsing
            Write-Host "Download successful."
            return $true
        } catch {
            Write-Host "Attempt $($retryCount) failed: $($_.Exception.Message)"
            Start-Sleep -Seconds 5
        }
    } while ($retryCount -lt $maxRetries)
    Write-Error "Failed to download CMake after $maxRetries attempts."
    exit 1
}

# Function to extract the ZIP file
function Extract-Zip {
    param (
        [string]$zipPath,
        [string]$outputPath
    )
    try {
        Write-Host "Extracting $zipPath to $outputPath..."
        Expand-Archive -Path $zipPath -DestinationPath $outputPath -Force
        Write-Host "Extraction complete."
    } catch {
        Write-Error "Failed to extract $zipPath: $($_.Exception.Message)"
        exit 1
    }
}

# Function to update the PATH environment variable
function Update-Path {
    param (
        [string]$newPath
    )
    try {
        Write-Host "Updating PATH to include $newPath..."
        [Environment]::SetEnvironmentVariable("Path", "$($env:Path);$newPath", [System.EnvironmentVariableTarget]::Machine)
        Write-Host "PATH updated successfully."
    } catch {
        Write-Error "Failed to update PATH: $($_.Exception.Message)"
        exit 1
    }
}

# Main script logic
Write-Host "Starting CMake installation..."

# Ensure TEMP folder exists
if (!(Test-Path -Path "C:\TEMP")) {
    New-Item -ItemType Directory -Path "C:\TEMP" | Out-Null
}

# Download CMake
Download-File -url $url -outputPath $destination

# Extract the ZIP
Extract-Zip -zipPath $destination -outputPath $installPath

# Update PATH
Update-Path -newPath "$installPath\bin"

Write-Host "CMake installation completed successfully."