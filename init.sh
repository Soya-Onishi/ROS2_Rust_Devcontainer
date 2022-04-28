#!/bin/bash

wget https://raw.githubusercontent.com/ros2-rust/ros2_rust/master/ros2_rust_foxy.repos -P /tmp
vcs import src < /tmp/ros2_rust_foxy.repos

colcon build --packages-ignore rosidl_runtime_rs rclrs