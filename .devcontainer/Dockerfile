FROM debian:bullseye-slim AS unpacker

WORKDIR /root
RUN apt update && \
    apt upgrade -y && \
    apt install -y wget bzip2 lsb-release
RUN wget "https://github.com/ros2/ros2/releases/download/release-foxy-20220208/ros2-foxy-20220208-linux-focal-amd64.tar.bz2"
RUN tar xf ros2-foxy-20220208-linux-focal-amd64.tar.bz2

FROM ubuntu:20.04 AS base_builder

ARG UID=1000
ARG GID=1000
ARG USERNAME=vscode

RUN mkdir /opt/ros
COPY --from=unpacker /root/ros2-linux /opt/ros/foxy

RUN apt update && \
    apt upgrade -y && \
    apt install -y git curl gnupg2 lsb-release build-essential clang libclang-dev lldb python3-pip wget openssl libssl-dev nano
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key  -o /usr/share/keyrings/ros-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu focal main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

RUN apt update
RUN DEBIAN_FRONTEND=noninteractive apt install -y python3-rosdep python3-colcon-common-extensions ros-foxy-test-interface-files python3-vcstool 
RUN rosdep init && rosdep update
RUN CHOOSE_ROS_DISTRO=foxy && rosdep install --from-paths opt/ros/foxy/share --ignore-src --rosdistro $CHOOSE_ROS_DISTRO -y --skip-keys "console_bridge fastcdr fastrtps libopensplice67 libopensplice69 osrf_testing_tools_cpp poco_vendor rmw_connext_cpp rosidl_typesupport_connext_c rosidl_typesupport_connext_cpp rti-connext-dds-5.3.1 tinyxml_vendor tinyxml2_vendor urdfdom urdfdom_headers"

RUN groupadd -g ${GID} $USERNAME
RUN useradd -ms /bin/bash -u $UID -g $GID $USERNAME

USER ${USERNAME}
RUN mkdir -p /home/$USERNAME/workspace/src/ros2_rust
WORKDIR /home/$USERNAME/workspace
SHELL ["/bin/bash", "-c"]

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
RUN echo "source $HOME/.bash_profile" >> ~/.bashrc
RUN echo "source /opt/ros/foxy/setup.bash" >> ~/.bash_profile
RUN echo "export PATH=$PATH:$HOME/.cargo/bin" >> ~/.bash_profile

RUN pip install git+https://github.com/colcon/colcon-cargo.git git+https://github.com/colcon/colcon-ros-cargo.git
RUN source ~/.bash_profile && cargo install cargo-ament-build

RUN wget https://raw.githubusercontent.com/ros2-rust/ros2_rust/master/ros2_rust_foxy.repos -P /tmp
RUN vcs import src < /tmp/ros2_rust_foxy.repos
