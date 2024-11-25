param(
    [string]$VS_VERSION = $env:VS_VERSION,
    [string[]]$Workloads = @("Microsoft.VisualStudio.Workload.VCTools"),
    [string]$InstallerPath = (Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath "vs_buildtools.exe"),
    [string]$LogPath = (Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath "vs_buildtools_install.log")
)

# Validate required parameters
if (-not $VS_VERSION) {
    throw "Visual Studio version is not specified. Please provide -VS_VERSION parameter or set the VS_VERSION environment variable."
}

Write-Host "Starting Visual Studio Build Tools installation for Version: $VS_VERSION"

# Resolve environment variable and construct the download URL
$resolvedVSVersion = $env:VS_VERSION
if (-not $resolvedVSVersion) {
    throw "Environment variable VS_VERSION is not set or is empty."
}
$VS_BUILD_TOOLS_URL = "https://aka.ms/vs/$resolvedVSVersion/release/vs_buildtools.exe"
Write-Host "Constructed Build Tools URL: $VS_BUILD_TOOLS_URL"

function Install-VSBuildTools {
    param(
        [string]$InstallerPath,
        [string[]]$Workloads,
        [string]$LogPath
    )

    # Retry logic for downloading the installer
    $maxAttempts = 3
    for ($attempt = 1; $attempt -le $maxAttempts; $attempt++) {
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Downloading Visual Studio Build Tools... Attempt $attempt"
        try {
            Invoke-WebRequest -Uri $VS_BUILD_TOOLS_URL -OutFile $InstallerPath -UseBasicParsing
            if ((Get-Item $InstallerPath).Length -ge 1MB) {
                Write-Host "Download successful! File size: $([Math]::Round((Get-Item $InstallerPath).Length / 1MB, 2)) MB"
                break
            } else {
                throw "Downloaded file is too small."
            }
        } catch {
            Write-Host "Download failed: $_"
            if ($attempt -eq $maxAttempts) {
                throw "Exceeded maximum download attempts. Please check the URL and network connection."
            }
            Start-Sleep -Seconds 5
        }
    }

    # Build the argument list
    $arguments = @(
        "--quiet",
        "--wait",
        "--norestart",
        "--nocache",
        "--installPath C:\\BuildTools"
    )

    foreach ($workload in $Workloads) {
        $arguments += "--add"
        $arguments += $workload
    }

    $arguments += @(
        "--includeRecommended",
        "--lang en-US",
        "--log `"$LogPath`""
    )

    # Start the installation
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Starting Visual Studio Build Tools installation..."
    Write-Host "Installer arguments: $($arguments -join ' ')"
    try {
        $startTime = Get-Date
        $process = Start-Process -FilePath $InstallerPath -ArgumentList $arguments -NoNewWindow -Wait -PassThru
        if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
            $endTime = Get-Date
            $duration = $endTime - $startTime
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Installation completed in $([Math]::Round($duration.TotalMinutes, 2)) minutes."
        } else {
            throw "Installer exited with code $($process.ExitCode). Check the log at $LogPath"
        }
    } catch {
        throw "Visual Studio Build Tools installation failed: $_"
    }
}

# Execute the installation function
Install-VSBuildTools -InstallerPath $InstallerPath -Workloads $Workloads -LogPath $LogPath

# Clean up installer
Remove-Item -Path $InstallerPath -Force

Write-Host "Visual Studio Build Tools installation completed successfully."
