FROM crossplatformapp-windows-base AS vs_build

ARG VS_YEAR=2017
ARG VS_VERSION=15
ARG CMAKE_VERSION=3.21.3

ENV VS_YEAR=${VS_YEAR} \
    VS_VERSION=${VS_VERSION} \
    CMAKE_VERSION=${CMAKE_VERSION}

COPY scripts/windows/install_vs_buildtools.ps1 C:/scripts/install_vs_buildtools.ps1
COPY scripts/windows/install_cmake_bypass.ps1 C:/scripts/install_cmake_bypass.ps1
COPY scripts/windows/build.ps1 C:/app/scripts/windows/build.ps1
COPY scripts/windows/run.ps1 C:/app/scripts/windows/run.ps1

RUN powershell -Command Write-Output "VS_VERSION is $($env:VS_VERSION); VS_YEAR is $($env:VS_YEAR); CMAKE_VERSION is $($env:CMAKE_VERSION)"

CMD ["powershell", "C:/app/scripts/windows/run.ps1"]