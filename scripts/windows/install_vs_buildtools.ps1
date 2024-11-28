param (
    [string]$VS_VERSION = "17", # Default to Visual Studio 2022 (Build Tools)
    [string]$INSTALL_PATH = "$env:ProgramFiles(x86)\Microsoft Visual Studio\$VS_VERSION\BuildTools",
    [string]$WORKLOAD = "Microsoft.VisualStudio.Workload.AzureBuildTools"
)

# Set variables
$vsBootstrapperUrl = "https://aka.ms/vs/$VS_VERSION/release/vs_buildtools.exe"
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
$installCommand = "& `"$vsInstaller`" --quiet --wait --norestart --nocache --installPath `"$INSTALL_PATH`" --add $WORKLOAD --remove Microsoft.VisualStudio.Component.Windows10SDK.10240 --remove Microsoft.VisualStudio.Component.Windows10SDK.10586 --remove Microsoft.VisualStudio.Component.Windows10SDK.14393 --remove Microsoft.VisualStudio.Component.Windows81SDK"

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