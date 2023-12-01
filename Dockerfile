
# there are 2 different ros repos used for different things. 
# this ros base layer allows the use of GUI apps such as Rviz. 
FROM osrf/ros:humble-desktop-full

# adding the sourcing of setup file to the .bashrc script
RUN echo "source /opt/ros/humble/setup.bash" >> "$HOME/.bashrc"

RUN apt-get update \
  && apt-get install -y \
  python3 \
  python3-pip \
  # nano \
  gedit \
  # x11-apps \
  # icecream \
  ~nros-humble-rqt* \
  && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir icecream
# RUN pip install --no-cache-dir --upgrade pip && \
#     pip install --no-cache-dir icecream

COPY config/ /site_config/

# Create a non-root user
ARG USERNAME=ros
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# creates a home directory and a config directory for the user
RUN groupadd --gid $USER_GID $USERNAME \
  && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME && echo \
  && mkdir /home/$USERNAME/.config && chown $USER_UID:$USER_GID /home/$USERNAME/.config

# means anything ran after this will be ran as the user
USER ros

# means anything ran after this will be ran as root. 
# Whatever the last user was set too will be the user when the dockerfile is ran. 
USER root 

# Set up sudo, setting up sudo previeralges, setting up not needed a password when sudo is ran. 
RUN apt-get update \
  && apt-get install -y sudo \
  && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
  && chmod 0440 /etc/sudoers.d/$USERNAME \
  && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
COPY bashrc /home/${USERNAME}/.bashrc
RUN echo "source install/setup.bash" >> "$HOME/.bashrc"


# setting up a ros2_workspace called workspace 
RUN mkdir -pv /home/user/workspace/src
WORKDIR /home/user/workspace/src
# following the Read me of the ROS_LLM github page
RUN git clone https://github.com/bgiffo96/PANDA-LLM.git
WORKDIR /home/user/workspace/src/PANDA-LLM/llm_install
RUN chmod +x dependencies_install.sh 
RUN bash dependencies_install.sh
RUN echo "export OPENAI_API_KEY=ADD YOUR API KEY HERE" >> "$HOME/.bashrc"
# # set up OpenAI Whisper
# RUN pip install --no-cache-dir --upgrade pip && \
#     pip install --no-cache-dir -U openai-whisper setuptools-rust

# complie using colcon build to establish our worksapce as a ros2 worksapce.
WORKDIR /home/user/workspace/
RUN rosdep install -r --from-paths src -i -y --rosdistro humble
RUN . /opt/ros/$ROS_DISTRO/setup.sh && \
  colcon build --symlink-install

ENTRYPOINT [ "/bin/bash", "/entrypoint.sh" ]

CMD ["bash"]


