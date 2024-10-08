#!/bin/sh

# Function to display usage information
usage() {
    echo "Usage: $0 -m <mitigation> [options]"
    echo
    echo "This script runs Scenic experiments with different mitigation strategies and models."
    echo
    echo "Options:"
    echo "  -m <strategy>  Mitigation strategy (behaviour or model)"
    echo
    echo "Mitigation-specific options:"
    echo "  Behaviour mitigation:"
    echo "    No additional options required"
    echo
    echo "  Model mitigation:"
    echo "    -y <type>    YOLOv5 model type (s, m, fine_tune, few_shot)"
    echo
    echo "Examples:"
    echo "  $0 -m behaviour"
    echo "  $0 -m model -y m"
    echo "  $0 -m model -y fine_tune"
    exit 1
}

# Initialize variables
mitigation=""
yolo_model=""

# Parse command line arguments
while [ $# -gt 0 ]; do
    case "$1" in
        -m) mitigation="$2"; shift 2 ;;
        -y) yolo_model="$2"; shift 2 ;;
        -h) usage ;;
        *) echo "Unknown option: $1"; usage ;;
    esac
done

# Function to run Scenic file
run_scenic() {
    file="scenic-repo/demonstrators/$1"
    if [ -f "$file" ]; then
        echo "Running: $file with YOLO model: $YOLO_MODEL"
        scenic "$file" --2d --simulate
    else
        echo "Error: File $file not found."
        exit 1
    fi
}

# Run scenarios based on user input
case "$mitigation" in
    behaviour)
        export YOLO_MODEL="yolov5s"
        run_scenic "behaviour_mitigation.scenic"
        ;;
    model)
        if [ -z "$yolo_model" ]; then
            echo "Error: YOLO model type (-y) is required for model mitigation."
            usage
        fi
        case "$yolo_model" in
            s)
                export YOLO_MODEL="yolov5s"
                ;;
            m)
                export YOLO_MODEL="yolov5m"
                ;;
            fine_tune)
                export YOLO_MODEL="fine_tune"
                ;;
            few_shot)
                export YOLO_MODEL="few_shot"
                ;;
            *)
                echo "Error: Invalid YOLO model specified."
                usage
                ;;
        esac
        run_scenic "model_architecture_mitigation.scenic"
        ;;
    *)
        echo "Error: Invalid mitigation strategy or missing required arguments."
        usage
        ;;
esac