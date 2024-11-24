Function Install-BuildTools {
    param(
        [string]$InstallerPath,
        [string]$InstallArgs
    )
    $installLogPath = "C:\temp\vs_buildtools_install.log"
    if (-not (Test-Path "C:\temp")) {
        New-Item -ItemType Directory -Path "C:\temp" | Out-Null
    }
    Log-Info "Starting Build Tools installation..."
    & $InstallerPath $InstallArgs > $installLogPath 2>&1
    if ($LASTEXITCODE -ne 0) {
        Log-Error "Build Tools installation failed. Full Installation Log:"
        Get-Content $installLogPath | ForEach-Object { Write-Host $_ }
        throw "Failed to install Build Tools. Check the log: $installLogPath"
    }
    Log-Info "Build Tools installed successfully."
}