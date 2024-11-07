
# CrossPlatformApp

CrossPlatformApp is a simple, cross-platform C++ application designed to demonstrate how to build and run C++ projects using `CMake` and Docker. The project is configured to be built on both Linux and Windows environments using Docker containers, making it easy to develop and deploy on multiple platforms.

## Project Structure

```
/CrossPlatformApp
|-- /src
|   |-- main.cpp             # Main C++ source file
|-- CMakeLists.txt           # CMake configuration file
|-- Dockerfile               # Dockerfile for Linux build
|-- Dockerfile.windows       # Dockerfile for Windows build
|-- .dockerignore            # File to exclude unnecessary files from Docker
|-- .github/workflows
    |-- docker-build-and-run.yml  # GitHub Actions workflow for CI/CD
```

## Prerequisites

- **Docker**: Ensure Docker is installed and running on your system.
- **CMake**: Used for building the project (included in the Docker images).

## Building and Running Locally

### Linux

1. **Build the Docker image**:
   ```bash
   docker build -t crossplatformapp-linux -f Dockerfile .
   ```

2. **Run the Docker container**:
   ```bash
   docker run --rm crossplatformapp-linux
   ```

### Windows

1. **Build the Docker image**:
   ```bash
   docker build -t crossplatformapp-windows -f Dockerfile.windows .
   ```

2. **Run the Docker container**:
   ```bash
   docker run --rm crossplatformapp-windows
   ```

## Project Configuration

### CMakeLists.txt

The `CMakeLists.txt` file defines how the project is built:

```cmake
cmake_minimum_required(VERSION 3.10)
project(CrossPlatformApp)

set(CMAKE_CXX_STANDARD 17)

add_executable(CrossPlatformApp src/main.cpp)
```

## GitHub Actions Workflow

This project includes a CI/CD setup using GitHub Actions:

- **File**: `.github/workflows/docker-build-and-run.yml`
- **Description**: The workflow builds and runs the project on both Linux and Windows using Docker.

### Workflow Triggers

The workflow is triggered on:
- **Push** events to the `main` branch.
- **Pull requests** to the `main` branch.

### Example Workflow

```yaml
name: Docker Build and Run CrossPlatformApp

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  build-and-run-linux:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Build Docker image
        run: docker build -t crossplatformapp-linux -f Dockerfile .

      - name: Run Docker container
        run: docker run --rm crossplatformapp-linux

  build-and-run-windows:
    runs-on: windows-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Build Docker image
        run: docker build -t crossplatformapp-windows -f Dockerfile.windows .

      - name: Run Docker container
        run: docker run --rm crossplatformapp-windows
```

## Notes

- **Cross-Platform Support**: This project is designed to be easily built and run on both Linux and Windows using Docker.
- **Dockerfiles**: Separate Dockerfiles are provided for Linux and Windows builds.

## Contributing

Contributions are welcome! If you'd like to contribute, please fork the repository and submit a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
