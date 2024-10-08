#!/bin/bash
sudo xhost +local:*

# Function to display menu and get user choice
get_user_choice() {
    echo "Please select an option:"
    echo "1) Run experiments"
    echo "2) Run mitigation"
    echo "3) Run default scenic simulation"
    echo "4) Exit"
    read -p "Enter your choice (1-4): " choice
}

# Main loop
while true; do
    get_user_choice

    case $choice in
        1)
            echo "Running experiments..."
            echo "Please enter experiment parameters:"
            read -p "Enter parameters: " params
            /execute_experiments.sh $params
            ;;
        2)
            echo "Running mitigation..."
            /execute_mitigation.sh
            ;;
        3)
            echo "Running default scenic simulation..."
            scenic /scenic-repo/demonstrators/st_world.scenic --2d --simulate
            ;;
        4)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac

    echo "Press Enter to continue..."
    read
done