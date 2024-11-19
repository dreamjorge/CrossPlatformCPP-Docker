[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Check if CMake is already installed
$cmakeVersion = (cmake --version 2>$null | Select-String -Pattern "^cmake version (\d+\.\d+\.\d+)" | ForEach-Object { $_.Matches.Groups[1].Value })
if ($cmakeVersion -eq $env:CMAKE_VERSION) {
    Write-Host "CMake $env:CMAKE_VERSION is already installed."
} else {
    Write-Host "Installing CMake $env:CMAKE_VERSION..."
    choco install cmake --version=$env:CMAKE_VERSION --installargs 'ADD_CMAKE_TO_PATH=System' -y
}
