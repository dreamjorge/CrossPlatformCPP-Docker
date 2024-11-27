name: Docker Build and Run on Windows Runner

# Trigger the workflow on push and pull request events to the main branch
on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  build-and-run-windows-docker:
    name: Build and Run Docker (Windows)
    runs-on: windows-latest

    # Define a matrix to allow for different configurations (e.g., Debug/Release)
    strategy:
      matrix:
        config: [Release]
    env:
      DOCKER_IMAGE_NAME: crossplatformapp-windows
      DOCKER_CONTAINER_NAME: crossplatformapp-container
      VS_VERSION: 16
      # CMAKE_VERSION: 3.26.4  # Removed to eliminate the warning

    steps:
      # Step 1: Checkout the repository code
      - name: Checkout Code
        uses: actions/checkout@v3
        with:
          fetch-depth: 0  # Fetch all history for branches and tags

      # Step 2: Create Host Temp Directory
      - name: Create Host Temp Directory
        shell: pwsh
        run: |
          New-Item -ItemType Directory -Path "${{ github.workspace }}\Temp" -Force

      # Step 3: Login to Docker Hub (if using a private repository)
      # Uncomment if Docker Hub authentication is required
      # - name: Log in to Docker Hub
      #   uses: docker/login-action@v2
      #   with:
      #     username: ${{ secrets.DOCKER_USERNAME }}
      #     password: ${{ secrets.DOCKER_PASSWORD }}

      # Step 4: Build the Docker image
      - name: Build Docker Image
        shell: pwsh
        run: |
          docker build --no-cache `
            --build-arg VS_VERSION=$env:VS_VERSION `
            -t $env:DOCKER_IMAGE_NAME `
            -f Dockerfile.windows.vs .

      # Step 5: List Docker Images (Commented Out)
      # - name: List Docker Images
      #   shell: pwsh
      #   run: |
      #     docker images

      # Step 6: Run Build Inside Docker (Commented Out)
      # - name: Run Build Inside Docker
      #   shell: pwsh
      #   run: |
      #     $config = "${{ matrix.config }}"
      #     docker run --rm --name $env:DOCKER_CONTAINER_NAME `
      #       -e CONFIG=$config `
      #       -e VS_VERSION=$env:VS_VERSION `
      #       -v "${{ github.workspace }}:C:/app" `
      #       -v "${{ github.workspace }}\Temp:C:/TEMP" `
      #       $env:DOCKER_IMAGE_NAME `
      #       powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-Location C:/app/scripts/windows; .\build.ps1 -CONFIG $config -VS_VERSION $env:VS_VERSION"

      # Step 7: Run Application Inside Docker (Commented Out)
      # - name: Run Application Inside Docker
      #   shell: pwsh
      #   run: |
      #     $config = "${{ matrix.config }}"
      #     docker run --rm --name $env:DOCKER_CONTAINER_NAME `
      #       -e CONFIG=$config `
      #       -v "${{ github.workspace }}:C:/app" `
      #       -v "${{ github.workspace }}\Temp:C:/TEMP" `
      #       $env:DOCKER_IMAGE_NAME `
      #       powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-Location C:/app/scripts/windows; .\run.ps1 -CONFIG $config"

      # Step 8: Extract Build Tools Installation Log
      - name: Extract Build Tools Installation Log
        shell: pwsh
        run: |
          docker create --name extract-log $env:DOCKER_IMAGE_NAME
          docker cp extract-log:C:/TEMP/vs_buildtools_install.log $env:GITHUB_WORKSPACE\Temp\vs_buildtools_install.log
          docker rm extract-log

      # Step 9: Display Build Tools Installation Log
      - name: Display Build Tools Installation Log
        shell: pwsh
        run: |
          if (Test-Path "Temp\vs_buildtools_install.log") {
            Write-Host "----- Begin vs_buildtools_install.log -----"
            Get-Content "Temp\vs_buildtools_install.log" | Write-Host
            Write-Host "----- End vs_buildtools_install.log -----"
          } else {
            Write-Host "vs_buildtools_install.log not found."
          }

      # Step 10: Upload Logs
      - name: Upload Logs
        if: failure()
        uses: actions/upload-artifact@v3
        with:
          name: vs-buildtools-log
          path: Temp\vs_buildtools_install.log  # Host path after mounting

      # Step 11: Cleanup Docker Containers
      - name: Cleanup Docker Resources
        if: always()
        shell: pwsh
        run: |
          docker ps -a -q --filter "name=$env:DOCKER_CONTAINER_NAME" | ForEach-Object { docker rm -f $_ }