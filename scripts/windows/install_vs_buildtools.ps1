param (
    [string]$VS_VERSION = $env:VS_VERSION
)

if (-not $VS_VERSION) {
    Write-Error "VS_VERSION is not specified."
    exit 1
}

$vsBootstrapperUrl = if ($VS_VERSION -eq "16") {
    "https://aka.ms/vs/16/release/vs_buildtools.exe"
} elseif ($VS_VERSION -eq "17") {
    "https://aka.ms/vs/17/release/vs_buildtools.exe"
} else {
    Write-Error "Unsupported VS_VERSION: $VS_VERSION."
    exit 1
}

$vsInstaller = "C:\TEMP\vs_buildtools.exe"

Write-Host "Downloading Visual Studio Build Tools..."
Invoke-WebRequest -Uri $vsBootstrapperUrl -OutFile $vsInstaller -UseBasicParsing

Write-Host "Installing Visual Studio Build Tools..."
try {
    Invoke-Expression "& `"$vsInstaller`" --quiet --wait --norestart --nocache --installPath `"$env:ProgramFiles(x86)\Microsoft Visual Studio\$VS_VERSION\BuildTools`" --add Microsoft.VisualStudio.Workload.AzureBuildTools"
    Write-Host "Installation successful."
} catch {
    Write-Error "Installation failed. Exit code: $LASTEXITCODE"
    exit $LASTEXITCODE
}

Write-Host "Cleaning up..."
Start-Sleep -Seconds 5
try {
    Remove-Item -Path $vsInstaller -Force -ErrorAction Stop
    Write-Host "Cleanup completed."
} catch {
    Write-Warning "Failed to remove installer. Skipping cleanup."
}

$installPath = "$env:ProgramFiles(x86)\Microsoft Visual Studio\$VS_VERSION\BuildTools"
if (Test-Path $installPath) {
    Write-Host "Validation successful: Visual Studio installed at $installPath."
} else {
    Write-Error "Validation failed: Installation directory not found."
    exit 1
}