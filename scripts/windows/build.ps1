Param (
    [string]$CONFIG,
    [string]$VS_VERSION
)

# Initialize logging
$LOG_FILE = "$env:APP_WORKDIR\build.log"
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
    "ERROR: Missing CONFIG parameter (Debug/Release)" | Out-File $LOG_FILE -Append
    exit 1
}
if (-not $VS_VERSION) {
    "ERROR: Missing VS_VERSION parameter (15/16/17)" | Out-File $LOG_FILE -Append
    exit 1
}

"Using CONFIG=$CONFIG and VS_VERSION=$VS_VERSION" | Out-File $LOG_FILE -Append

# Log current directory and its contents
"=== Current Directory: $(Get-Location) ===" | Out-File $LOG_FILE -Append
Get-ChildItem | Out-File $LOG_FILE -Append
"=================================" | Out-File $LOG_FILE -Append

# Initialize Visual Studio environment
$vsDevCmd = "C:\BuildTools\Common7\Tools\VsDevCmd.bat"
"Initializing Visual Studio environment with $vsDevCmd" | Out-File $LOG_FILE -Append
& cmd /c """$vsDevCmd""" >> $LOG_FILE 2>&1
if ($LASTEXITCODE -ne 0) {
    "ERROR: Failed to initialize Visual Studio environment" | Out-File $LOG_FILE -Append
    exit 1
}

# Validate CMake installation
"Validating CMake installation..." | Out-File $LOG_FILE -Append
cmake --version >> $LOG_FILE 2>&1
if ($LASTEXITCODE -ne 0) {
    "ERROR: CMake is not installed or not in PATH!" | Out-File $LOG_FILE -Append
    exit 1
}

# Run CMake configuration
"Running CMake configuration..." | Out-File $LOG_FILE -Append
cmake -S $env:APP_WORKDIR -B "$env:APP_WORKDIR\build" -DCMAKE_BUILD_TYPE=$CONFIG >> $LOG_FILE 2>&1
if ($LASTEXITCODE -ne 0) {
    "ERROR: CMake configuration failed" | Out-File $LOG_FILE -Append
    exit 1
}

# Build project
"Building project..." | Out-File $LOG_FILE -Append
cmake --build "$env:APP_WORKDIR\build" --config $CONFIG >> $LOG_FILE 2>&1
if ($LASTEXITCODE -ne 0) {
    "ERROR: Build failed" | Out-File $LOG_FILE -Append
    exit 1
}

# Success
"Build completed successfully at $(Get-Date)" | Out-File $LOG_FILE -Append
exit 0
