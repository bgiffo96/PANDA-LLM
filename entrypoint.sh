#!/bin/bash

# enables error signals
set -e
# sources the ros installation
# source /opt/ros/humble/setup.bash
# print what ever is passed to it
echo "provided arguments: $@"
# executes the command
exec $@