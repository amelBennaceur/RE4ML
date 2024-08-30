# RE4ML
primary repo for all RE4ML experiments

# RE4ML Project Documentation

## Table of Contents
- [RE4ML Project Documentation](#re4ml-project-documentation)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Prerequisites](#prerequisites)
  - [System Setup](#system-setup)
  - [Running the Project](#running-the-project)
  - [Running Experiments](#running-experiments)
  - [Running Mitigation](#running-mitigation)
  - [Notes on Running Scripts](#notes-on-running-scripts)
  - [Troubleshooting](#troubleshooting)

## Introduction

This document provides instructions for setting up and running the RE4ML project. The project uses Docker to create a controlled environment for running experiments and simulations.

## Prerequisites

Before you begin, ensure you have the following installed on your system:
- Docker
- Docker Compose
- Git

## System Setup

1. Clone the repository:
   ```
   git clone https://github.com/pradeep5267/RE4ML.git
   cd RE4ML
   ```

2. Switch to the `artefacts_deployable` branch:
   ```
   git checkout artefacts_deployable
   ```

3. Run the system setup script:
   ```
   chmod +x system_setup/prebuild.sh
   sudo ./system_setup/prebuild.sh
   ```
## Running the Project
1. Build and start the Docker container using the `spinup.sh` script:
   ```
   chmod +x spinup.sh
   ./spinup.sh
   ```

Once the Docker container is built and running (after using `spinup.sh`), you can interact with the project using the `access.sh` script.

2. Run the access script:
   ```
   ./access.sh
   ```

This will open an interactive terminal inside the Docker container, where you can run experiments and simulations.


## Running Experiments

To run experiments, use the `execute_experiments.sh` script. This script allows you to run various Scenic experiments with different parameters.

Usage:
```
./execute_experiments.sh -e <experiment> [options]
```

Options:
- `-e <number>`: Experiment number (1, 2, 3, or 4)

Experiment-specific options:
1. Experiment 1:
   - `-a <group>`: Age group (adult or child)
   - `-m <type>`: YOLOv5 model type (s for small, m for medium) [optional]

2. Experiment 2:
   - `-d <length>`: Distance (short or long)
   - `-p <dir>`: Position (LR or RL)
   - `-a <group>`: Age group (adult or child)

3. Experiment 3:
   - `-a <group>`: Age group (adult or child)
   - `-c <type>`: Condition (light or dark)

4. Experiment 4:
   - `-a <group>`: Age group (adult or child)

Examples:
```
./execute_experiments.sh -e 1 -a adult -m s
./execute_experiments.sh -e 2 -a child -d short -p LR
./execute_experiments.sh -e 3 -a adult -c light
./execute_experiments.sh -e 4 -a child
```

## Running Mitigation

To run mitigation strategies, use the `execute_mitigation.sh` script. This script allows you to run Scenic experiments with different mitigation strategies and models.

Usage:
```
./execute_mitigation.sh -m <mitigation> [options]
```

Options:
- `-m <strategy>`: Mitigation strategy (behaviour or model)

Mitigation-specific options:
1. Behaviour mitigation:
   - No additional options required

2. Model mitigation:
   - `-y <type>`: YOLOv5 model type (s, m, fine_tune, few_shot)

Examples:
```
./execute_mitigation.sh -m behaviour
./execute_mitigation.sh -m model -y m
./execute_mitigation.sh -m model -y fine_tune
```

## Notes on Running Scripts

1. Both scripts should be run from within the Docker container, which you can access using the `access.sh` script as described earlier.

2. Make sure the scripts are executable. If they're not, you can make them executable using:
   ```
   chmod +x execute_experiments.sh execute_mitigation.sh
   ```

3. The scripts will run Scenic simulations based on the provided parameters. Ensure that all necessary Scenic files are present in the `scenic-repo/demonstrators/` directory within the container.

4. For experiments, the script will automatically set the YOLO_MODEL environment variable based on the parameters you provide.

5. For mitigation, you can choose between behaviour mitigation (which uses YOLOv5s by default) and model mitigation (where you can specify the YOLO model type).

6. If you encounter any "file not found" errors, double-check that the Scenic files are in the correct location within the container.

7. You can always use the `-h` option with either script to display the usage information:
   ```
   ./execute_experiments.sh -h
   ./execute_mitigation.sh -h
   ```

By using these scripts, you can easily run different experiments and mitigation strategies as part of the RE4ML project. The scripts provide a convenient way to set up the correct parameters and environment variables for each scenario.

## Troubleshooting

If you encounter any issues:

1. Ensure all scripts (`spinup.sh`, `access.sh`, `startup.sh`, `execute_experiments.sh`, `execute_mitigation.sh`) are executable. If not, make them executable using `chmod +x <script_name>`.

2. If you face permission issues, try running the scripts with `sudo`.

3. For X11 forwarding issues (if the GUI doesn't appear), ensure you've run `xhost +local:*` on your host machine before starting the container.

4. If the container fails to start or build, check the output of the `spinup.sh` script for any error messages.

5. To check the status of the Docker container:
   ```
   docker ps
   ```

6. To view the logs of the container:
   ```
   docker logs c3
   ```

7. If you need to rebuild the container, you can use:
   ```
   ./spinup.sh
   ```

8. For any other issues, refer to the error messages in the terminal or check the project's GitHub issues page for known problems and solutions.

