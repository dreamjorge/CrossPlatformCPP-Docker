param (
    [string]$VS_VERSION = $env:VS_VERSION # Default to environment variable if not passed
)

# Validate that VS_VERSION is provided
if (-not $VS_VERSION) {
    Write-Error "VS_VERSION is not specified. Provide it as an argument or set it as an environment variable."
    exit 1
}

# Construct the download URL based on VS_VERSION
if ($VS_VERSION -eq "16") {
    $vsBootstrapperUrl = "https://aka.ms/vs/16/release/vs_buildtools.exe"
} elseif ($VS_VERSION -eq "17") {
    $vsBootstrapperUrl = "https://aka.ms/vs/17/release/vs_buildtools.exe"
} else {
    Write-Error "Unsupported VS_VERSION: $VS_VERSION. Only 16 and 17 are supported."
    exit 1
}

$vsInstaller = "C:\TEMP\vs_buildtools.exe"

Write-Host "Downloading Visual Studio Build Tools version $VS_VERSION from $vsBootstrapperUrl..."

# Download the Visual Studio Build Tools bootstrapper
try {
    Invoke-WebRequest -Uri $vsBootstrapperUrl -OutFile $vsInstaller -UseBasicParsing
    Write-Host "Download successful: $vsInstaller"
} catch {
    Write-Error "Failed to download Visual Studio Build Tools. Error: $($_.Exception.Message)"
    exit 1
}

Write-Host "Installing Visual Studio Build Tools version $VS_VERSION..."

# Install Visual Studio Build Tools
$installCommand = "& `"$vsInstaller`" --quiet --wait --norestart --nocache --installPath `"$env:ProgramFiles(x86)\Microsoft Visual Studio\$VS_VERSION\BuildTools`" --add Microsoft.VisualStudio.Workload.AzureBuildTools --remove Microsoft.VisualStudio.Component.Windows10SDK.10240 --remove Microsoft.VisualStudio.Component.Windows10SDK.10586 --remove Microsoft.VisualStudio.Component.Windows10SDK.14393 --remove Microsoft.VisualStudio.Component.Windows81SDK"

try {
    Invoke-Expression $installCommand
    Write-Host "Visual Studio Build Tools installation completed successfully."
} catch {
    if ($LASTEXITCODE -eq 3010) {
        Write-Host "Installation succeeded but requires a restart (ignored for container builds)."
    } else {
        Write-Error "Visual Studio Build Tools installation failed. Exit code: $LASTEXITCODE"
        exit $LASTEXITCODE
    }
}

# Cleanup
Write-Host "Cleaning up temporary files..."
Remove-Item -Path $vsInstaller -Force
Write-Host "Cleanup completed."
