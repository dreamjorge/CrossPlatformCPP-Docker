param(
    [string]$CMAKE_VERSION = $env:CMAKE_VERSION
)

# Validate required parameter
if (-not $CMAKE_VERSION) {
    throw "CMake version is not specified. Please provide -CMAKE_VERSION parameter or set the CMAKE_VERSION environment variable."
}

Write-Host "Installing CMake version $CMAKE_VERSION"

# Download URL for CMake
$CMakeUrl = "https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION-windows-x86_64.msi"
Write-Host "CMake Download URL: $CMakeUrl"

# Download and install CMake
$InstallerPath = (Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath "cmake.msi")
Invoke-WebRequest -Uri $CMakeUrl -OutFile $InstallerPath -UseBasicParsing

# Install CMake silently
Write-Host "Installing CMake..."
Start-Process msiexec.exe -ArgumentList "/i `"$InstallerPath`" /quiet /qn /norestart" -Wait

# Add CMake to PATH
$cmakePath = "C:\Program Files\CMake\bin"
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";$cmakePath", [EnvironmentVariableTarget]::Machine)

# Clean up installer
Remove-Item -Path $InstallerPath -Force

Write-Host "CMake installation completed successfully."