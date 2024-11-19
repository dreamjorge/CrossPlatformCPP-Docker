[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
if (-not $env:CMAKE_VERSION) {
    Write-Host "INFO: CMAKE_VERSION not set. Defaulting to 3.21.3."
    $env:CMAKE_VERSION = "3.21.3"
}
choco install cmake --version=$env:CMAKE_VERSION --installargs 'ADD_CMAKE_TO_PATH=System' -y
