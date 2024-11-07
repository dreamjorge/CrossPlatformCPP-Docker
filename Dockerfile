# Use an official Ubuntu base image
FROM ubuntu:20.04

# Set non-interactive mode to prevent prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
# Install build tools and CMake
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy the project files into the container
COPY . .

# Create a build directory and compile the project
RUN mkdir -p build && cd build && cmake .. && make

# Run the compiled executable
CMD ["./build/CrossPlatformApp"]
