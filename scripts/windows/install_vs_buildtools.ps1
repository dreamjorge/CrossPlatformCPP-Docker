param(
    [string]$VS_YEAR = $env:VS_YEAR,
    [string]$VS_VERSION = $env:VS_VERSION,
    [string]$Workloads = "Microsoft.VisualStudio.Workload.AzureBuildTools;Microsoft.VisualStudio.Workload.VCTools",
    [string]$InstallerPath = (Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath "vs_buildtools.exe")
)

# Validate required parameters
if (-not $VS_YEAR) {
    throw "Visual Studio year is not specified. Please provide -VS_YEAR parameter or set the VS_YEAR environment variable."
}

if (-not $VS_VERSION) {
    throw "Visual Studio version is not specified. Please provide -VS_VERSION parameter or set the VS_VERSION environment variable."
}

# Rest of your script...

Write-Host "Starting Visual Studio Build Tools installation for Year: $VS_YEAR, Version: $VS_VERSION"

function Get-VSInstaller {
    param(
        [string]$VS_YEAR,
        [string]$InstallerPath,
        [int]$RetryCount = 3
    )

    $VS_BUILD_TOOLS_URL = "https://aka.ms/vs/$VS_YEAR/release/vs_buildtools.exe"
    Write-Host "Build Tools URL: $VS_BUILD_TOOLS_URL"

    for ($i = 1; $i -le $RetryCount; $i++) {
        try {
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Downloading Visual Studio Build Tools... Attempt $i"
            Invoke-WebRequest -Uri $VS_BUILD_TOOLS_URL -OutFile $InstallerPath -UseBasicParsing
            if ((Test-Path $InstallerPath) -and ((Get-Item $InstallerPath).Length -gt 0)) {
                Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Download successful! File size: $([Math]::Round((Get-Item $InstallerPath).Length / 1MB, 2)) MB"
                return
            } else {
                throw "File appears to be empty or invalid."
            }
        } catch {
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Download failed: $_"
            if ($i -eq $RetryCount) {
                throw "[$(Get-Date -Format 'HH:mm:ss')] Failed to download Visual Studio Build Tools after $RetryCount attempts."
            } else {
                Start-Sleep -Seconds 5
            }
        }
    }
}

function Install-VSBuildTools {
    param(
        [string]$InstallerPath,
        [string]$Workloads
    )

    if (-not (Test-Path $InstallerPath)) {
        throw "Installer file not found at $InstallerPath."
    }

    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Starting Visual Studio Build Tools installation..."
    try {
        $startTime = Get-Date
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Installation in progress. This may take some time..."

        # Build argument list
        $arguments = @(
            "--quiet",
            "--wait",
            "--norestart",
            "--nocache",
            "--installPath `"$env:ProgramFiles(x86)\Microsoft Visual Studio\$VS_YEAR\BuildTools`"",
            "--add $Workloads",
            "--remove Microsoft.VisualStudio.Component.Windows10SDK.10240",
            "--remove Microsoft.VisualStudio.Component.Windows10SDK.10586",
            "--remove Microsoft.VisualStudio.Component.Windows10SDK.14393",
            "--remove Microsoft.VisualStudio.Component.Windows81SDK",
            "--includeRecommended",
            "--includeOptional",
            "--lang en-US"
        )

        $argumentString = $arguments -join ' '
        $process = Start-Process -FilePath $InstallerPath -ArgumentList $argumentString -NoNewWindow -Wait -PassThru

        if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
            $endTime = Get-Date
            $duration = $endTime - $startTime
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Installation completed in $([Math]::Round($duration.TotalMinutes, 2)) minutes."
        } else {
            throw "Installer exited with code $($process.ExitCode)."
        }
    } catch {
        throw "Visual Studio Build Tools installation failed: $_"
    }
}

function Main {
    param(
        [string]$VS_YEAR,
        [string]$VS_VERSION,
        [string]$Workloads,
        [string]$InstallerPath
    )

    # Ensure InstallerPath directory exists
    $installerDir = Split-Path -Path $InstallerPath -Parent
    if (-not (Test-Path -Path $installerDir)) {
        Write-Host "Creating directory $installerDir..."
        New-Item -ItemType Directory -Path $installerDir -Force | Out-Null
    }

    # Download the installer
    Get-VSInstaller -VS_YEAR $VS_YEAR -InstallerPath $InstallerPath

    # Install Build Tools
    Install-VSBuildTools -InstallerPath $InstallerPath -Workloads $Workloads

    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Visual Studio Build Tools installation completed successfully."
}

# Execute the main function
Main -VS_YEAR $VS_YEAR -VS_VERSION $VS_VERSION -Workloads $Workloads -InstallerPath $InstallerPath
