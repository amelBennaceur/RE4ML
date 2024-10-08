#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Function to check if Docker Compose is available
check_docker_compose() {
    if ! command -v docker &> /dev/null; then
        echo "Error: Docker is not installed. Please install Docker and try again."
        exit 1
    fi

    if ! docker compose version &> /dev/null; then
        echo "Error: Docker Compose V2 is not available. Please ensure you have Docker Compose V2 integrated with Docker."
        exit 1
    fi
}

# Check for Docker Compose availability
check_docker_compose

export DOCKER_BUILDKIT=1
PROJECT_NAME="carla"

echo "Stopping existing containers and removing images..."
docker compose -f carla-compose.yml -p $PROJECT_NAME down --rmi all

echo "Building and starting Docker containers..."
if docker compose -f carla-compose.yml -p $PROJECT_NAME up -d --build; then
    echo "Containers are up and running."
    
    # Wait for a few seconds to ensure the container is fully started
    sleep 5
    
    echo "Containers are ready. You can now run the execute_mitigation or execute_experiment scripts."
    echo "Opening a new terminal..."
    
    # Open a new terminal
    if command -v gnome-terminal &> /dev/null; then
        gnome-terminal
    elif command -v xterm &> /dev/null; then
        xterm
    else
        echo "Could not find a suitable terminal emulator. Please open a new terminal manually."
    fi
else
    echo "Error: Build or startup failed. Checking logs..."
    docker compose -f carla-compose.yml -p $PROJECT_NAME logs
    exit 1
fi