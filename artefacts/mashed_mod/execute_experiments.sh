#!/bin/sh

# Function to display usage information
usage() {
    echo "Usage: $0 -e <experiment> [options]"
    echo
    echo "This script runs various Scenic experiments with different parameters."
    echo
    echo "Options:"
    echo "  -e <number>    Experiment number (1, 2, 3, or 4)"
    echo
    echo "Experiment-specific options:"
    echo "  Experiment 1:"
    echo "    -a <group>   Age group (adult or child)"
    echo "    -m <type>    YOLOv5 model type (s for small, m for medium) [optional]"
    echo
    echo "  Experiment 2:"
    echo "    -d <length>  distance (short or long)"
    echo "    -p <dir>     Position (LR or RL)"
    echo "    -a <group>   Age group (adult or child)"
    echo
    echo "  Experiment 3:"
    echo "    -a <group>   Age group (adult or child)"
    echo "    -c <type>    Condition (light or dark)"
    echo
    echo "  Experiment 4:"
    echo "    -a <group>   Age group (adult or child)"
    echo
    echo "Examples:"
    echo "  $0 -e 1 -a adult -m s"
    echo "  $0 -e 2 -a child -d short -p LR"
    echo "  $0 -e 3 -a adult -c light"
    echo "  $0 -e 4 -a child"
    exit 1
}

# Initialize variables
experiment=""
distance=""
position=""
age=""
condition=""
model="s"  # Default to small model

# Parse command line arguments
while [ $# -gt 0 ]; do
    case "$1" in
        -e) experiment="$2"; shift 2 ;;
        -d) distance="$2"; shift 2 ;;
        -p) position="$2"; shift 2 ;;
        -a) age="$2"; shift 2 ;;
        -c) condition="$2"; shift 2 ;;
        -m) model="$2"; shift 2 ;;
        -h) usage ;;
        *) echo "Unknown option: $1"; usage ;;
    esac
done

# Function to run Scenic file
run_scenic() {
    file="scenic-repo/demonstrators/$1"
    echo "$file"
    if [ -f "$file" ]; then
        echo "Running: $file with model yolov5$model"
        export YOLO_MODEL="yolov5$model"
        scenic "$file" --2d --simulate
    else
        echo "Error: File $file not found."
        exit 1
    fi
}

# Validate model if provided for Experiment 1
if [ "$experiment" = "1" ] && [ -n "$model" ]; then
    if [ "$model" != "s" ] && [ "$model" != "m" ]; then
        echo "Error: Invalid model specified for Experiment 1. Use 's' for small or 'm' for medium."
        usage
    fi
fi

# Run scenarios based on user input
case "$experiment" in
    1)
        if [ -z "$age" ]; then
            echo "Error: Age (-a) is required for Experiment 1."
            usage
        fi
        run_scenic "experiment1_${age}.scenic"
        ;;
    2)
        if [ -z "$distance" ] || [ -z "$position" ] || [ -z "$age" ]; then
            echo "Error: distance (-d), position (-p), and age (-a) are required for Experiment 2."
            usage
        fi
        run_scenic "experiment2$(echo "$distance" | sed 's/.*/\u&/')${position}_${age}.scenic"
        ;;
    3)
        if [ -z "$age" ] || [ -z "$condition" ]; then
            echo "Error: Age (-a) and condition (-c) are required for Experiment 3."
            usage
        fi
        run_scenic "experiment3_${condition}_${age}.scenic"
        ;;
    4)
        if [ -z "$age" ]; then
            echo "Error: Age (-a) is required for Experiment 4."
            usage
        fi
        run_scenic "experiment4_fog_${age}.scenic"
        ;;
    *)
        echo "Error: Invalid experiment number or missing required arguments."
        usage
        ;;
esac
