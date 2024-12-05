Param (
    [string]$CONFIG,
    [string]$VS_VERSION
)

# Determine the root of the repository
if (-not $env:APP_WORKDIR) {
    # Get the directory of the script
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    # Assume the root of the repository is the parent directory of the script directory
    $env:APP_WORKDIR = Split-Path -Parent $scriptDir
    Write-Host "APP_WORKDIR not set. Using repository root: $env:APP_WORKDIR"
}

# Initialize logging
$LOG_FILE = "$env:APP_WORKDIR\build.log"
Write-Host "Starting build process at $(Get-Date)"
Write-Host "Logging to $LOG_FILE"
"Starting build process at $(Get-Date)" | Out-File $LOG_FILE
"Logging to $LOG_FILE" | Out-File $LOG_FILE -Append

# Use CONFIG and VS_VERSION from environment variables if parameters are not provided
if (-not $CONFIG) {
    $CONFIG = $env:CONFIG
}
if (-not $VS_VERSION) {
    $VS_VERSION = $env:VS_VERSION
}

# Validate parameters
if (-not $CONFIG) {
    $errorMsg = "ERROR: Missing CONFIG parameter (Debug/Release)"
    Write-Host $errorMsg
    $errorMsg | Out-File $LOG_FILE -Append
    exit 1
}
if (-not $VS_VERSION) {
    $errorMsg = "ERROR: Missing VS_VERSION parameter (15/16/17)"
    Write-Host $errorMsg
    $errorMsg | Out-File $LOG_FILE -Append
    exit 1
}

Write-Host "Using CONFIG=$CONFIG and VS_VERSION=$VS_VERSION"
"Using CONFIG=$CONFIG and VS_VERSION=$VS_VERSION" | Out-File $LOG_FILE -Append

# Function to get the path to VsDevCmd.bat
function Get-VsDevCmdPath {
    param([string]$vsVersion)

    $vsDevCmdPath = $null

    # Check for BuildTools path (Docker image)
    $buildToolsPath = "C:\BuildTools\Common7\Tools\VsDevCmd.bat"
    if (Test-Path $buildToolsPath) {
        return $buildToolsPath
    }

    # Determine VS year based on version number
    switch ($vsVersion) {
        "15" { $vsYear = "2017" }
        "16" { $vsYear = "2019" }
        "17" { $vsYear = "2022" }
        default {
            $errorMsg = "ERROR: Unsupported VS_VERSION=$vsVersion"
            Write-Host $errorMsg
            $errorMsg | Out-File $LOG_FILE -Append
            exit 1
        }
    }

    # Possible editions of Visual Studio
    $vsEditions = @("Community", "Professional", "Enterprise", "BuildTools")

    # Possible Program Files directories
    $programFilesDirs = @(
        "${env:ProgramFiles(x86)}",
        "${env:ProgramFiles}"
    )

    foreach ($programFiles in $programFilesDirs) {
        foreach ($edition in $vsEditions) {
            $vsDevCmdCandidate = Join-Path -Path $programFiles -ChildPath "Microsoft Visual Studio\$vsYear\$edition\Common7\Tools\VsDevCmd.bat"
            if (Test-Path $vsDevCmdCandidate) {
                return $vsDevCmdCandidate
            }
        }
    }

    # If not found, return null
    return $null
}

# Get the path to VsDevCmd.bat
$vsDevCmd = Get-VsDevCmdPath -vsVersion $VS_VERSION

if (-not $vsDevCmd) {
    $errorMsg = "ERROR: Could not find VsDevCmd.bat for VS_VERSION=$VS_VERSION"
    Write-Host $errorMsg
    $errorMsg | Out-File $LOG_FILE -Append
    exit 1
}

Write-Host "Initializing Visual Studio environment with $vsDevCmd"
"Initializing Visual Studio environment with $vsDevCmd" | Out-File $LOG_FILE -Append

# Initialize the Visual Studio environment
& "$vsDevCmd" | Out-File $LOG_FILE -Append 2>&1
if ($LASTEXITCODE -ne 0) {
    $errorMsg = "ERROR: Failed to initialize Visual Studio environment"
    Write-Host $errorMsg
    $errorMsg | Out-File $LOG_FILE -Append
    exit 1
}

# Validate CMake installation
Write-Host "Validating CMake installation..."
"Validating CMake installation..." | Out-File $LOG_FILE -Append
cmake --version | Tee-Object -Variable cmakeVersion | Out-File $LOG_FILE -Append 2>&1
if ($LASTEXITCODE -ne 0) {
    $errorMsg = "ERROR: CMake is not installed or not in PATH!"
    Write-Host $errorMsg
    $errorMsg | Out-File $LOG_FILE -Append
    exit 1
}

Write-Host "CMake Version:"
Write-Host $cmakeVersion

# Run CMake configuration
Write-Host "Running CMake configuration..."
"Running CMake configuration..." | Out-File $LOG_FILE -Append
cmake -S $env:APP_WORKDIR -B "$env:APP_WORKDIR\build" -DCMAKE_BUILD_TYPE=$CONFIG | Tee-Object -Variable cmakeConfigOutput | Out-File $LOG_FILE -Append 2>&1
if ($LASTEXITCODE -ne 0) {
    $errorMsg = "ERROR: CMake configuration failed"
    Write-Host $errorMsg
    Write-Host $cmakeConfigOutput
    $errorMsg | Out-File $LOG_FILE -Append
    exit 1
}

# Build project
Write-Host "Building project..."
"Building project..." | Out-File $LOG_FILE -Append
cmake --build "$env:APP_WORKDIR\build" --config $CONFIG | Tee-Object -Variable cmakeBuildOutput | Out-File $LOG_FILE -Append 2>&1
if ($LASTEXITCODE -ne 0) {
    $errorMsg = "ERROR: Build failed"
    Write-Host $errorMsg
    Write-Host $cmakeBuildOutput
    $errorMsg | Out-File $LOG_FILE -Append
    exit 1
}

# Success
Write-Host "Build completed successfully at $(Get-Date)"
"Build completed successfully at $(Get-Date)" | Out-File $LOG_FILE -Append
exit 0
