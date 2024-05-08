---
title: "Set up GUI in Container"
subtitle: "Set up GUI in Container" 
categories: user
tags: user
layout: post
---


Recently, I found myself delving into a project that demanded running **a labeling application built on the Vispy framework**. Originally developed on a Windows Subsystem for Linux (WSL) environment, attempting to run it on Ubuntu led to **OpenGL-related errors**, such as:
![](/assets/img/2024-05-08/error1.png){:height="360px" width="640px"}

Fig1 Error1
{:.figcaption}

![](/assets/img/2024-05-08/error2.png){:height="360px" width="640px"}

Fig2 Error2
{:.figcaption}


I tried `pip3 install PyOpenGL==3.1.7` to change its version. But both of them has the issue that `from OpenGL import GL` would fail. Fearing potential system instability, I opted to encapsulate the application within a Docker container. 


# Find a Suitable GUI Image 
As the task involved visualization and manual labeling, I scoured GitHub and stumbled upon a publicly shared repository named [gui-docker](https://github.com/bandi13/gui-docker). This repository offered a VNC-enabled GUI setup, which perfectly suited my needs. Setting it up was straightforward:

```shell
git clone https://github.com/bandi13/gui-docker
cd {path to gui-docker}
docker build . 
```

Upon successful image creation, running `docker images -a` confirmed the existence of a new image named `gui-docker`. Subsequently, launching the container and accessing it was achieved using:

```shell
docker run <image id> -it --name <container name> bash
```
Additional terminal access to the running container was facilitated through `docker exec -it <container id> bash`

To ensure GUI functionality, running `xeyes` within the container shell and navigating to `localhost:5901` in a web browser displayed a pair of eyes


# Install Necessary Packages in the GUI Image
**Customizing the container** to accommodate project-specific requirements involved installing essential packages and addressing user permission concerns. 

You can note down the packages installed on this GUI Container and finalize it as a Dockerfile. The Dockerfile for my repository looked as follows:
```shell
# Use Ubuntu 22.04 as base image
FROM bandi13/gui-docker

USER root 

# Update the system
RUN apt-get update
RUN apt-get install -y x11-apps

# Install vim
RUN apt-get install -y vim
RUN apt-get install -y git
# -y for confirmation 

# Install libglfw3
RUN apt-get install -y libglfw3

# Install pip
RUN apt-get install -y python3-pip
RUN apt-get install -y python3-tk
RUN apt-get install -y libglib2.0-0
RUN pip install vispy pyopengltk 

# Copy requirements.txt to the docker image and install Python packages
COPY requirements.txt .
RUN pip install -r requirements.txt
```
Noteworthy was the **adjustment of the user to root** during image creation to facilitate hassle-free package installations
> The base image `gui-docker` would assign the user as non-root user

# Create a Labelling App Image 
Utilizing this Dockerfile, a labelling app image would be created. And **the user would be the root**. 

For setting up a container from this new image, suggest to use `docker-compuse.yaml`, especially if the container requires several volumne mount or port information. The `docker-compose.yaml` format would be like the following: 

```bash
version: '3' # compose file version

services:
  gui-dairy-farm-dataset-v1:
    image: veraz00/gui-dairy-farm-dataset-v1:v1 
    volumes:
      - /home/linlin/Workspace/01_FeedRunnerOfficial/dairy-farm-dataset:/dairy-farm-dataset
      - /home/linlin/Dataset/01_FeedRunnerOfficial:/Dataset
    environment:
      - DISPLAY=:0
      - VNC_PASSWD=123456
    shm_size: 256m
    ports:
      - "5901:5901"
    
    stdin_open: true  # open the standard input
    tty: true # open the terminal
    restart: "no"
    command: /bin/bash
```
> `stdin_open`: Keeps stdin open for Docker service

> `tty`: Allocates a pseudo-TTY for Docker service

> `restart`: Sets the restart policy for Docker container

Then you can run the following to get the container: 
```bash
cd <directory of docker-compose.yaml>
docker compose up
```

# Update the Labelling App Image 
Any missed packages can be installed directly within the new container. Additionally, you have the option to utilize `docker commit <container id> <image_name>:<tag>` to capture the changes made to the container and create a new image. 

This ensures that future instances of the image will already include the newly installed packages 


# PyopenGL Issue 
However, I met **the same PyopenGL error** when running labelling app inside the container, I refered to [this blog](https://blog.csdn.net/sinat_33896833/article/details/107362959) to solve it. **Thanks for those anonymous contributors a lot!** 

# Lessons Learned: Overcoming Hurdles
Throughout this endeavor, several obstacles were encountered and addressed:

## Fail1: Set up X11 

Initially, I aimed to leverage the **X11 GUI server to establish display connections between the container and the host server**. This involved granting access to X11 and configuring display settings within the Docker container. 

Despite these efforts, the attempt led to a frustrating error:

```
File "/usr/lib/python3.10/tkinter/__init__.py", line 2299, in __init__
  self.tk = _tkinter.create(screenName, baseName, className, interactive, wantobjects, useTk, sync, use)
 _tkinter.TclError: couldn't connect to display ":1" ON CONTAINER

```
The steps I did are the following: 

1. Open the access to X11 to any user 
```
ls -al /tmp/.X11-unix
chmod a+r /tmp/.X11-unix/*
xhost

```
2. Mount the access 
```
docker run -i -t --rm \
--net=host \
-v /tmp:/tmp \
--env DISPLAY=$DISPLAY \
--env XAUTHORITY=/tmp/.docker.xauth \
--name dairy-farm-dataset-linlin \
--mount src=/home/linlin/Workspace/01_FeedRunnerOfficial/dairy-farm-dataset,target=/dairy-farm-dataset,type=bind \
--mount src=/home/linlin/Dataset/01_FeedRunnerOfficial,target=/Dataset/01_FeedRunnerOfficial,type=bind \
dairy-farm-dataset bash
```


So I dig into how to solve it. When running `Xorg` on hostmachine, I got:
```
/usr/lib/xorg/Xorg.wrap: Only console users are allowed to run the X server
```
When run `gdm`, it raises error: 
```
Only the root user can run GDM
```
It shows the current username has no permission to create a display, which requires root priviledge to operate. This may explain the fails. After that, I stopped this direction, then tried the `xvfp`


## Fail2: Utilize xvfp 

With reference to [3. Using x11vnc](https://www.baeldung.com/linux/docker-container-gui-applications*), I set up **xvfp in a hostmachine** with the following commands:  
```shell 
sudo apt-get install xvfb 
Xvfb :99 -screen 0 1024x768x24 # set $DISPLAY from xvfb as :99
```

Then create a container by setting `dislay =:99`, the one display port from `xvfb`: 

```shell
docker run -i -t --rm \
--net=host \
-v /tmp:/tmp \
--env DISPLAY=:99 \
--name dairy-farm-dataset-xvfb \
--mount src=/home/linlin/Workspace/01_FeedRunnerOfficial/dairy-farm-dataset,target=/dairy-farm-dataset,type=bind \
--mount src=/home/linlin/Dataset/01_FeedRunnerOfficial,target=/Dataset/01_FeedRunnerOfficial,type=bind \
dairy-farm-dataset bash
```
On the other hand, it only creates a virtual display, which requires a vnc or other software to display it. so sad. 

That drives me to look into **VNC** directly.



# Refer 
1. Use VNC to Set up GUI for container: https://github.com/bandi13/gui-docker
2. Install OpenGL in Linux: https://blog.csdn.net/sinat_33896833/article/details/107362959
3. Docker container gui applications: https://www.baeldung.com/linux/docker-container-gui-applications*
