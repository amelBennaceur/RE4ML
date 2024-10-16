# SET SCENARIO PARAMETERS AND MODEL 
import carla
import logging
import time
import os
import sys
import random

# Define the weather conditions
weather = {
    "cloudiness":50,
    "precipitation":0,
    "sun_azimuth_angle":120,
    "sun_altitude_angle":60,
    "fog_density": 0
}

def get_all_pedestrian_models():
    return [model for model in carla_simulator.blueprints.walkerModels]

# Apply the weather conditions to the scenario
param map = localPath('/opt/carla/CarlaUE4/Content/Carla/Maps/OpenDrive/Town01.xodr')
param carla_map = 'Town01'
model scenic.simulators.carla.model  # Here the definitions of all referenceables are defined (vehicle types, road library, etc) 
import scenic.simulators.carla as carla_simulator
param weather = weather
# SCENARIO CONSTANTS 
EGO_MODEL = "vehicle.tesla.model3"
PEDESTRIAN_MODELS = get_all_pedestrian_models()
PEDESTRIAN_MODEL = Uniform(*PEDESTRIAN_MODELS)
EGO_SPEED = 8
SAFETY_DISTANCE = 10
BRAKE_INTENSITY = 1.0
PEDESTRIAN_MIN_SPEED = 1.0
THRESHOLD = 8

# SENSOR ATTRIBUTES
attrs = {"image_size_x": 640,
         "image_size_y": 640}

## DEFINING SPATIAL RELATIONS
lane = Uniform(*network.lanes)
spot = new OrientedPoint on lane.centerline
vending_spot = new OrientedPoint following roadDirection from spot for -3

# logging.info('class: child')
# BEHAVIORS: 
# behavior Exp_EgoBehaviour():
#     try:
#         do FollowLaneBehavior(target_speed=10)
#     interrupt when checkCautionBehaviour(ego.observations["front_rgb"], pedestrian.position, ego.position):
#         adjusted_brake_value = checkCautionBehaviour(ego.observations["front_rgb"], pedestrian.position, ego.position)
#         print(f'target braking: {adjusted_brake_value}')
#         take SetBrakeAction(adjusted_brake_value)
#     interrupt when checkPedestrianDectectedFlag(ego.observations["front_rgb"], pedestrian.position, ego.position):
#         print('yolo emergency braking')
#         take YoloEmergencyBraking()

behavior Exp_EgoBehaviour():
    try:
        do FollowLaneBehavior(target_speed = EGO_SPEED)
    interrupt when checkPedestrianDectectedFlag(ego.observations["front_rgb"], pedestrian.position, ego.position):
        print('yolo emergency braking')
        take YoloEmergencyBraking()

behavior PedestrianBehavior(min_speed=1, threshold=THRESHOLD):
    do CrossingBehavior(ego, min_speed, threshold)

# Define ranges for randomization
LATERAL_RANGE = Range(-3, 3)  # -3 to 3 meters laterally
FORWARD_RANGE = Range(8, 12)  # 8 to 12 meters ahead

pedestrian = new Pedestrian at (LATERAL_RANGE, FORWARD_RANGE, 0) relative to spot,
    with heading 90 deg relative to roadDirection,
    with regionContainedIn None,  # Allow the actor to spawn outside the driving lanes
    with behavior PedestrianBehavior(PEDESTRIAN_MIN_SPEED, THRESHOLD),
    with blueprint PEDESTRIAN_MODEL

vending_machine = new VendingMachine right of vending_spot by 3,
    with heading 90 deg relative to vending_spot.heading,
    with regionContainedIn None  # Allow the actor to spawn outside the driving lanes

ego = new Car following roadDirection from spot for -15,
    with blueprint EGO_MODEL,
    with sensors {"front_rgb": RGBSensor(offset=(1.6, 0, 1.7), attributes=attrs)}, #(201 -> low) (x-> horizontal front back, y -> horizontal left right, z -> vertical up down)
    with behavior Exp_EgoBehaviour()

# RECORDING SETUP
record ego.observations["front_rgb"] as "front_rgb"
require monitor RecordingMonitor(ego, path=localPath(f"/home/recording/temp"), recording_start=5, subsample=2)

# REQUIREMENTS
require (distance to intersection) > 30
require (distance from spot to intersection) > 30
require always (ego.laneSection._slowerLane is None)
require always (ego.laneSection._fasterLane is None)

# TERMINATION CONDITION
terminate when (distance to spot) > 30