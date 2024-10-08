# SET SCENARIO PARAMETERS AND MODEL 
import carla
import logging
import time
import os
import sys
#from scenic.log_utils import setup_logging
import random

# Define the weather conditions
weather = {
    "cloudiness":50,
    "precipitation":0,
    "sun_azimuth_angle":120,
    "sun_altitude_angle":60,
    "fog_density": 0
}

# Apply the weather conditions to the scenario
param map = localPath('/opt/carla/CarlaUE4/Content/Carla/Maps/OpenDrive/Town01.xodr')
param carla_map = 'Town01'

model scenic.simulators.carla.model  # Here the definitions of all referenceables are defined (vehicle types, road library, etc) 
param weather = weather
# SCENARIO CONSTANTS 
EGO_MODEL = "vehicle.tesla.model3"
PEDESTRIAN_MODEL = "walker.pedestrian.0011"
# PEDESTRIAN_MODELS = [
#     "walker.pedestrian.0048",
#     "walker.pedestrian.0001",
#     "walker.pedestrian.0011",  # Add as many models as you have
#     # ... other pedestrian models
# ]


EGO_SPEED = 8
SAFETY_DISTANCE = 10
BRAKE_INTENSITY = 1.0

PEDESTRIAN_MIN_SPEED = 1.0
THRESHOLD = 16

# SENSOR ATTRIBUTES
attrs = {"image_size_x": 640,
         "image_size_y": 640}

## DEFINING SPATIAL RELATIONS
# lane = Uniform(*network.lanes)
all_lane = (network.lanes)
lane = all_lane[2] # lane2 => clean, lane 20 => cluttered
# for i in range(len(all_lane)):
#     if all_lane[i].uid == 'road10_lane1':
#         print(i)
    # print(dir(all_lane[0]), all_lane[0].uid)
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
        do FollowLaneBehavior(target_speed = 10)
    interrupt when checkPedestrianDectectedFlag(ego.observations["front_rgb"], pedestrian.position, ego.position):
        print('yolo emergency braking')
        take YoloEmergencyBraking()

# behavior EgoBehavior(speed=10):
#     try:
#         do FollowLaneBehavior(target_speed=speed)
#     interrupt when withinDistanceToObjsInLane(self, SAFETY_DISTANCE):
#         print('safety dist violated')
#         take SetBrakeAction(BRAKE_INTENSITY)

behavior PedestrianBehavior(min_speed=1, threshold=8):
    do CrossingBehavior(ego, min_speed, threshold)

# Define ranges for randomization
# LATERAL_RANGE = Range(-3, 3)  # -3 to 3 meters laterally
# FORWARD_RANGE = Range(8, 12)  # 8 to 12 meters ahead

# pedestrian = new Pedestrian at (LATERAL_RANGE, FORWARD_RANGE, 0) relative to spot,
#     with heading 90 deg relative to roadDirection,
#     with regionContainedIn None,  # Allow the actor to spawn outside the driving lanes
#     with behavior PedestrianBehavior(PEDESTRIAN_MIN_SPEED, THRESHOLD),
#     with blueprint PEDESTRIAN_MODEL

pedestrian = new Pedestrian at (1, 13, 0) relative to spot,
    with heading 90 deg relative to spot.heading,
    with regionContainedIn None,  # Allow the actor to spawn outside the driving lanes
    with behavior PedestrianBehavior(PEDESTRIAN_MIN_SPEED, THRESHOLD),
    with blueprint PEDESTRIAN_MODEL
# pedestrian = new Pedestrian right of spot by 3,
#     with heading 90 deg relative to spot.heading,
#     with regionContainedIn None,  # Allow the actor to spawn outside the driving lanes
#     with behavior PedestrianBehavior(PEDESTRIAN_MIN_SPEED, THRESHOLD),
#     with blueprint PEDESTRIAN_MODEL

vending_machine = new VendingMachine right of vending_spot by 3,
    with heading 90 deg relative to vending_spot.heading,
    with regionContainedIn None  # Allow the actor to spawn outside the driving lanes

ego = new Car following roadDirection from spot for -15,
    with blueprint EGO_MODEL,
    with sensors {"front_rgb": RGBSensor(offset=(1.6, 0, 1.7), attributes=attrs)}, #(201 -> low) (x-> horizontal front back, y -> horizontal left right, z -> vertical up down)
    with behavior Exp_EgoBehaviour()

# RECORDING SETUP
record ego.observations["front_rgb"] as "front_rgb"

# record ego.observations["front_rgb"] as "front_rgb" after 5s every 1s # TODO Implement
# record ego.observations["front_rgb"] after 5s every 1s to localPath("data/generation") # TODO Implement

require monitor RecordingMonitor(ego, path=localPath(f"/home/recording/temp"), recording_start=5, subsample=2)


# REQUIREMENTS
require (distance to intersection) > 30
require (distance from spot to intersection) > 30
require always (ego.laneSection._slowerLane is None)
require always (ego.laneSection._fasterLane is None)

# TERMINATION CONDITION
terminate when (distance to spot) > 30