#!/bin/bash
sudo xhost +local:*
docker exec -u root c3 conda run --name env1 scenic /scenic-repo/Scenic-Sensors-Shenanigans-master/carla_scratchpad/scenic_meta_exps/scenic_exps/st2_world.scenic --2d --simulate