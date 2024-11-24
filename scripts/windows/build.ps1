# Build the project using Visual Studio
param(
    [string]$env:VS_YEAR,
    [string]$env:VS_VERSION
)

Write-Host "Building project with Visual Studio $($env:VS_YEAR), Version $($env:VS_VERSION)"

# Example build logic (adjust based on actual script logic)
$msbuildPath = "C:\Program Files (x86)\Microsoft Visual Studio\$($env:VS_YEAR)\BuildTools\MSBuild\Current\Bin\MSBuild.exe"
$solutionPath = "C:\app\solution.sln"

& $msbuildPath $solutionPath /p:Configuration=Release /p:Platform=x64