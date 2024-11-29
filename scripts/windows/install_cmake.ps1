# Read CMAKE_VERSION from the environment variable
$CMAKE_VERSION = $env:CMAKE_VERSION

# Validate version is provided
if (-not $CMAKE_VERSION) {
    Write-Error "CMAKE_VERSION is not specified."
    exit 1
}

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
            Write-Host ("Attempt {0}: Downloading CMake from {1}..." -f $retryCount, $url)
            Invoke-WebRequest -Uri $url -OutFile $outputPath -UseBasicParsing
            Write-Host "Download successful."
            return $true
        } catch {
            Write-Host ("Attempt {0} failed: {1}" -f $retryCount, $_.Exception.Message)
            Start-Sleep -Seconds 5
        }
    } while ($retryCount -lt $maxRetries)
    Write-Error ("Failed to download CMake after {0} attempts." -f $maxRetries)
    exit 1
}

# Function to extract the ZIP file
function Extract-Zip {
    param (
        [string]$zipPath,
        [string]$outputPath
    )
    try {
        Write-Host ("Extracting {0} to {1}..." -f $zipPath, $outputPath)
        Expand-Archive -Path $zipPath -DestinationPath $outputPath -Force
        Write-Host "Extraction complete."
    } catch {
        Write-Error ("Failed to extract {0}: {1}" -f $zipPath, $_.Exception.Message)
        exit 1
    }
}

# Function to update the PATH environment variable
function Update-Path {
    param (
        [string]$newPath
    )
    try {
        Write-Host ("Updating PATH to include {0}..." -f $newPath)
        [Environment]::SetEnvironmentVariable("Path", "$($env:Path);$newPath", [System.EnvironmentVariableTarget]::Machine)
        Write-Host "PATH updated successfully."
    } catch {
        Write-Error ("Failed to update PATH: {0}" -f $_.Exception.Message)
        exit 1
    }
}

# Function to validate installation
function Validate-Installation {
    param (
        [string]$cmakePath
    )
    try {
        Write-Host "Validating CMake installation..."
        $cmakeVersionOutput = & "$cmakePath\cmake.exe" --version
        if ($cmakeVersionOutput -like "*CMake $CMAKE_VERSION*") {
            Write-Host "CMake version $CMAKE_VERSION installed and verified successfully."
        } else {
            Write-Error "CMake installation validation failed. Installed version does not match the expected version."
            exit 1
        }
        Write-Host "Installed CMake version details:"
        Write-Host $cmakeVersionOutput
    } catch {
        Write-Error ("CMake validation failed: {0}" -f $_.Exception.Message)
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

# Validate installation and print version
Validate-Installation -cmakePath "$installPath\bin"

Write-Host "CMake installation completed successfully."
