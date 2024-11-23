
param (
    [string]$CMakeVersion = $env:CMAKE_VERSION
)

if ([string]::IsNullOrWhiteSpace($CMakeVersion)) {
    $CMakeVersion = "3.21.3"
}

$cmakeUrl = "https://github.com/Kitware/CMake/releases/download/v$CMakeVersion/cmake-$CMakeVersion-windows-x86_64.zip"
$cmakeZipPath = "C:\temp\cmake.zip"
$cmakeInstallPath = "C:\cmake"

# Download CMake zip
Write-Host "Downloading CMake from $cmakeUrl..."
Invoke-WebRequest -Uri $cmakeUrl -OutFile $cmakeZipPath

# Extract CMake
Write-Host "Extracting CMake to $cmakeInstallPath..."
Expand-Archive -Path $cmakeZipPath -DestinationPath $cmakeInstallPath

# Move extracted files to the install path
$extractedDir = Join-Path $cmakeInstallPath "cmake-$CMakeVersion-windows-x86_64"
if (Test-Path $extractedDir) {
    Write-Host "Moving files from $extractedDir to $cmakeInstallPath..."
    Get-ChildItem -Path $extractedDir | Move-Item -Destination $cmakeInstallPath -Force
    Remove-Item -Recurse -Force $extractedDir
}

# Clean up
Remove-Item -Force $cmakeZipPath

Write-Host "CMake installed successfully to $cmakeInstallPath."