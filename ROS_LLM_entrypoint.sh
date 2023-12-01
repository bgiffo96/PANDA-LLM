#!/bin/bash

git clone https://github.com/Auromix/ROS-LLM.git
cd ROS-LLM/llm_install
bash dependencies_install.sh
# adding OpenAI API key 
cd ROS-LLM/llm_install
bash config_openai_api_key.sh
echo "complete" 