# install_choco_cmake.ps1
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
choco install cmake --version=$env:CMAKE_VERSION --installargs 'ADD_CMAKE_TO_PATH=System' -y