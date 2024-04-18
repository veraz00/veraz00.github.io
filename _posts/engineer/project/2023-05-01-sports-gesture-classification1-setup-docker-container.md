---
layout: post
title: "Sports Gesture Classification1: Set up Docker Container"
subtitle: "Sports Gesture Classification1: Set up Docker Container"
category: engineer 
tags: project 
---

<!--more-->

* this unordered seed list will be replaced by the toc
{:toc}


From [Kaggle: Sports Gesture Classification Competition](https://www.kaggle.com/datasets/gpiosenka/sports-classification), I would use [SwinTransformer from Timm](https://www.kaggle.com/code/pkbpkb0055/99-2-classification-using-swin-transformer) to **build an inference API and set it on a container**

- Github: [Sports Gesture Classification on Docker](https://github.com/veraz00/sports_gesture_classification_on_docker)
- Demo for training and api prediction on Docker 
{{< youtube 2DWbemtVgis>}}



## Introduction to Docker 
**Docker** is a software platform that allows you to create and manage containers. A **Docker image** contains all the necessary files and dependencies to run an application, while a **container** is a running instance of that image. Containers provide an isolated and reproducible environment for running applications.
![](/assets/img/2023-05-01/docker_relationship.jpeg)

For docker container, it is similar to the **virtual machine platform**, except Docker is an operating system for containers. And the hardware source (ex. RAM, GPU) is used from the local.
![](/assets/img/2023-05-01/docker_container.png)


## Install Docker Server & Client 
First, you need to install Docker Server & Client on your system. Follow these steps:
1. Remove any previously installed Docker components:

    ```shell
    sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
    sudo rm -rf /var/lib/docker
    sudo rm -rf /var/lib/containerd
    ```
2. Install Docker

    ```shell
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
    ```
3. Verify the Docker installation by checking the version by checking `docker version` in terminal

Make sure the version information is displayed correctly as following.

![](/assets/img/2023-05-01/docker_version.jpg)




## Write Dockerfile 
A `Dockerfile` defines the steps and packages required to build the platform for your sports classification project. Here's an example `Dockerfile`.

```shell
FROM ubuntu:latest

RUN apt-get update && apt-get install -y git && \
    apt-get install -y python3-pip sudo vim wget && \ 
    rm -rf /var/lib/apt/lists/*

# The -m option of useradd command allows to copy all files from your system skeleton directory (/etc/skel) to the newly created home directory.
RUN useradd -m linlin 

# chown: add another layer on image 
# chown -R <past_owner>:<current_owner> the target directory
RUN chown -R linlin:linlin /home/linlin/  


# COPY --chown=<user>:<group> <hostPath> <containerPath>    
# do not copy environment into docker file, add environment path into `.dockerignore`
COPY --chown=linlin . /home/linlin/sport_gesture_classification_on_docker/

USER linlin

RUN cd /home/linlin/sport_gesture_classification_on_docker/ && pip3 install -r requirements.txt

WORKDIR /home/linlin/sport_gesture_classification_on_docker/
```
Let's break down this `Dockerfile`:

- It starts with the base image `ubuntu:latest`, which provides an Ubuntu-based environment and related packages.
- Necessary packages such as `git`, `python3-pip`, `sudo`, `vim`, and `wget` are installed.
- A system user named `linlin` is created with a home directory.
- The local project files are copied to the Docker image, specifically to `/home/linlin/sport_gesture_classification_on_docker/`. Make sure to add any necessary files or directories to `.dockerignore` to exclude them from the copy process, ex, virtual environment path.
- The user permissions are switched to linlin.
- The project's dependencies are installed using `pip3` within the project directory.
- The working directory is set to `/home/linlin/sport_gesture_classification_on_docker/`, which will be the default directory when the container starts.

For more details, you can go to check: [Dockerfile in Sports Gesture Classification on Docker](https://github.com/veraz00/sports_gesture_classification_on_docker/blob/main/Dockerfile)


## Create a Docker Container 
1. Build the Docker image by executing the following command in the same directory as the `Dockerfile`

    ```shell
    # build image 
    docker build -t sports_api:v1 .
    ```
    Here `sports_api:v1` is the name and tag you assign to the image. The `.` indicates that the `Dockerfile` is present in the current directory. 

    Building the image may take some time, and the resulting image size will be around 8.7 GB. You can use `docker image` to check the available images.
    ![](/assets/img/2023-05-01/sports_api_image.png)

2. Generate a container based on the built image

    ```shell
    docker run \
    -it \
    --rm \
    -p 12000:12000 \
    -p 6006:6006 \
    -v /home/linlin/dataset/sports_kaggle:/home/linlin/dataset/sports_kaggle \
    sports_api:v1
    ```
    Here's an explanation of the command:
    - `-t` enables the pseudo-terminal (TTY) for the container.
    - `-i` allows an interactive connection with the container.
    - `-p host_port:container_port` maps port 12000 for the Flask API and port 6006 for checking events in TensorBoard.
    - `-v $host_path:$container_path` mounts the local dataset directory `/home/linlin/dataset/sports_kaggle` into the container at the same path, allowing access to the dataset from within the container.
    - `sports_api:v1` refers to the image name and tag.

    After executing this command, you will enter an interactive terminal located inside the Docker container. 
    ![](/assets/img/2023-05-01/from_docker_run.png)
    You can use `docker ps` in the local terminal to check the available Docker containers.


## Training on docker 
On the Docker terminal, **the required packages and applications have already been installed** according to the `Dockerfile`. To train your model, run the following command:

```shell
python3 train.py
```
This command is the same as what you would run locally.

### Checking the Training Process using TensorBoard
To monitor the training process using TensorBoard:

1. Run the following command on the container to start TensorBoard:
    ```shell
    python3 -m tensorboard.main --logdir=. --bind_all
    ```
2. On your local machine, access TensorBoard by visiting `localhost:6006` in your web browser. **This is possible because you mapped port 6006 of the container to port 6006 on your local machine during the docker run command**.


### Set up the API
To set up the API on the container: 
1. Run the following command on the container:
    ```shell
    python3 api.py
    ```
    - From my view, we should not use config file to set up variables (e.g, what is the inference model?) when runing an api script, because those changable variables should be from the front end choice 
2. On your local machine, access the API by visiting `localhost:12000` in your web browser.


## Downloading the Model from Docker to Local
To download the model from the Docker container to your local machine, use the following command:
```shell
sudo docker cp <container_id>:<mnodel_path_on_docker> <local_path>
```
Replace `<container_id>` with the ID of the Docker container, `<model_path_on_docker>` with the path to the model file within the container, and `<local_path>` with the desired destination on your local machine.

## Saving the Docker Image
To save the Docker image for future use on any platform, follow these steps: 
1. Run the following command:
    ```shell
    docker save myimage:<tag> | gzip > docker_image_sports_api.tar.gz
    ```
2. The Docker image will be saved as docker_image_sports_api.tar.gz. You can now transfer and use this image on other platforms.


## Refer
1. This project is inspired by [How to train a deep learning model using docker?](https://www.youtube.com/watch?v=Kzrfw-tAZew)
2. Fask API Setting refers to https://github.com/abhishekkrthakur/sportsnoma-deep-learning
3. [Kaggle: Sports Gesture Classification](https://www.kaggle.com/datasets/gpiosenka/sports-classification)
4. [Kaggle Sports Gesture Competition: SwinTransformer from Timm](https://www.kaggle.com/code/pkbpkb0055/99-2-classification-using-swin-transformer)
5. [Official Docker Introduction](https://docs.docker.com/get-started/overview/)