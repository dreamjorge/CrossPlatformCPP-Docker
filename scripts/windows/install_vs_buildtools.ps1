param (
    [string]$VS_VERSION = $env:VS_VERSION
)

if (-not $VS_VERSION) {
    Write-Error "VS_VERSION is not specified."
    exit 1
}

$vsInstaller = "C:\TEMP\vs_buildtools.exe"
$vsBootstrapperUrl = if ($VS_VERSION -eq "16") {
    "https://aka.ms/vs/16/release/vs_buildtools.exe"
} elseif ($VS_VERSION -eq "17") {
    "https://aka.ms/vs/17/release/vs_buildtools.exe"
} else {
    Write-Error "Unsupported VS_VERSION: $VS_VERSION."
    exit 1
}

Write-Host "Downloading Visual Studio Build Tools..."
Invoke-WebRequest -Uri $vsBootstrapperUrl -OutFile $vsInstaller -UseBasicParsing

if (-not (Test-Path $vsInstaller)) {
    Write-Error "Installer download failed. File not found: $vsInstaller"
    exit 1
}

Write-Host "Installing Visual Studio Build Tools..."
try {
    & "$vsInstaller" --quiet --wait --norestart --nocache `
        --add Microsoft.VisualStudio.Workload.AzureBuildTools `
        --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
        --add Microsoft.VisualStudio.Component.Windows10SDK.19041 `
        --installPath "C:\Program Files (x86)\Microsoft Visual Studio\$VS_VERSION\BuildTools" `
        --log C:\TEMP\vs_install_log.txt
    Write-Host "Installation successful."
} catch {
    Write-Error "Installation failed. Error: $($_.Exception.Message)"
    exit 1
}

Write-Host "Validating installation..."
if (Test-Path "C:\Program Files (x86)\Microsoft Visual Studio\$VS_VERSION\BuildTools") {
    Write-Host "Validation successful: Installation directory found."
} else {
    Write-Error "Validation failed: Installation directory not found."
    exit 1
}

Write-Host "Cleaning up..."
Remove-Item -Path $vsInstaller -Force -ErrorAction SilentlyContinue