#!/bin/bash

# Name of the Docker container
CONTAINER_NAME="c3"

# User to run as
USER_NAME="carla"

# Directory to start in
WORK_DIR="/"

# Conda environment to activate
CONDA_ENV="env1"

# Function to check if the container is running
check_container() {
    if ! docker ps -q -f name=$CONTAINER_NAME | grep -q .; then
        echo "Error: Container $CONTAINER_NAME is not running."
        echo "Please ensure the container is started before running this script."
        exit 1
    fi
}

# Function to open a terminal in the container and run startup.sh
open_container_terminal() {
    echo "Opening a terminal for user $USER_NAME in container $CONTAINER_NAME..."
    echo "Starting in directory $WORK_DIR with conda environment $CONDA_ENV activated."
    echo "Running startup.sh with provided arguments."
    echo "To exit the container, type 'exit' or press Ctrl+D."
    echo "-------------------------------------------"
    
    # Use docker exec to start an interactive bash session in the container and run startup.sh
    docker exec -it --user $USER_NAME $CONTAINER_NAME /bin/bash -c "
        cd $WORK_DIR && 
        source /opt/conda/etc/profile.d/conda.sh && 
        conda activate /opt/conda/envs/$CONDA_ENV && 
        exec /bin/bash
    "
}

# Main script execution
check_container
open_container_terminal "$@"