param(
    [string]$VS_VERSION = $env:VS_VERSION,
    [string]$Workloads = "Microsoft.VisualStudio.Workload.AzureBuildTools;Microsoft.VisualStudio.Workload.VCTools",
    [string]$InstallerPath = (Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath "vs_buildtools.exe")
)

# Validate required parameters
if (-not $VS_VERSION) {
    throw "Visual Studio version is not specified. Please provide -VS_VERSION parameter or set the VS_VERSION environment variable."
}

Write-Host "Starting Visual Studio Build Tools installation for Version: $VS_VERSION"

# Corrected URL using VS_VERSION
$VS_BUILD_TOOLS_URL = "https://aka.ms/vs/$VS_VERSION/release/vs_buildtools.exe"
Write-Host "Build Tools URL: $VS_BUILD_TOOLS_URL"

function Install-VSBuildTools {
    param(
        [string]$InstallerPath,
        [string]$Workloads
    )

    # Download the installer
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Downloading Visual Studio Build Tools... Attempt 1"
    Invoke-WebRequest -Uri $VS_BUILD_TOOLS_URL -OutFile $InstallerPath -UseBasicParsing

    # Verify the downloaded file size (should be larger than 1 MB)
    if ((Get-Item $InstallerPath).Length -lt 1MB) {
        throw "Downloaded file is too small to be the correct installer. Please check the download URL."
    } else {
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Download successful! File size: $([Math]::Round((Get-Item $InstallerPath).Length / 1MB, 2)) MB"
    }

    # Build the argument list
    $arguments = @(
        "--quiet",
        "--wait",
        "--norestart",
        "--nocache",
        "--installPath `"$env:ProgramFiles(x86)\Microsoft Visual Studio\BuildTools`"",
        "--add $Workloads",
        "--includeRecommended",
        "--includeOptional",
        "--lang en-US",
        "--log `"$env:TEMP\vs_buildtools_install.log`""
    )

    $argumentString = $arguments -join ' '

    # Start the installation
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Starting Visual Studio Build Tools installation..."
    try {
        $startTime = Get-Date
        $process = Start-Process -FilePath $InstallerPath -ArgumentList $argumentString -NoNewWindow -Wait -PassThru

        # Handle exit codes
        if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
            $endTime = Get-Date
            $duration = $endTime - $startTime
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Installation completed in $([Math]::Round($duration.TotalMinutes, 2)) minutes."
        } else {
            throw "Installer exited with code $($process.ExitCode). Check the log at $env:TEMP\vs_buildtools_install.log"
        }
    } catch {
        throw "Visual Studio Build Tools installation failed: $_"
    }
}

# Execute the installation function
Install-VSBuildTools -InstallerPath $InstallerPath -Workloads $Workloads

# Clean up installer
Remove-Item -Path $InstallerPath -Force

Write-Host "Visual Studio Build Tools installation completed successfully."