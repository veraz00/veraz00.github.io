---
layout: post
title: "Sports Gesture Classification2: Build Dev Container"
subtitle: "Sports Gesture Classification1: Build Dev Container"
category: engineer 
tags: project 
---


<!--more-->

* this unordered seed list will be replaced by the toc
{:toc}



## Introduction to Dev Container 
Dev container as [Development Container on Vscode](https://code.visualstudio.com/docs/devcontainers/containers) here, provide a self-featured development environment which is able to run an application on a separate tools, libraries from the local environement.

### Features on Dev Container vs Docker Container 
- **Common1**: A separate environment with customization                   
- **Common2**: Any changes made to the container will be lost when the container is stopped. However, the changes can be saved by committing the container to a new image. This new image can then be used to start a new container with the changes
- **Difference**: Docker provides copy and mount features. However, **the former does not synchronize changes between Docker and the local environment, and vice versa**. In contrast, Dev Containers use a mount format for all files, ensuring that changes made locally or in Docker are synchronized on both platforms. 



## Set up Dev Container 
### Write Dockerfile 
To set up a Dev Container, begin by creating a `Dockerfile` with content similar to what to find in the **Sports Gesture Classification - Part1 Docker Container**. And place it in the project directory.

### Write Container Configuration File 
Next, create a configuration file `devcontainer.json` at `{project}/.devcontainer`. The format of this file should resemble the following:
```yaml
// README at: https://github.com/devcontainers/templates/tree/main/src/docker-existing-dockerfile
{
	"name": "Sports Gesture Classification Container",
	"build": {
		// Sets the run context to one level up instead of the .devcontainer folder.
		"context": "..",
		// Update the 'dockerFile' property if you aren't using the standard 'Dockerfile' filename.
		"dockerfile": "../Dockerfile"
	},
	"remoteUser": "linlin",
	"workspaceFolder": "/home/linlin/sport_gesture_classification_on_devcontainer",
	"mounts": [
		"source=/home/linlin/dataset/sports_kaggle/,target=/home/linlin/dataset/sports_kaggle,type=bind,consistency=cached",
	],
	"features": {
		"git": "latest"
	}
}
```

- The default `workspaceFolder` is `/home/{remoteUser}/workspace`. Its property is to match the location of your mounted project in the Dev Container. This ensures that when you connect to the Dev Container, **the terminal's path will automatically be set to your project directory**.

-  In `mount` property, the dataset is located at `/home/linlin/dataset/sports_kaggle/` on the host machine and is mounted at `/home/linlin/dataset/sports_kaggle` inside the dev container.
	> The `mounts` property is used to **specify the location of the dataset on the host machine and the location where it should be mounted inside the dev container**.	
- The `type` property is set to `bind`, which means that the dataset is mounted as a bind mount. 		
	> This allows the dataset to be shared between the host machine and the dev container, and any changes made to the dataset inside the dev container will be reflected on the host machine.
- The `consistency` property is set to `cached`
	> It means that the dataset is mounted with cached consistency. This provides better performance when reading from the dataset. 

### Install Dev Container on Vscode 
1. On Extensions on Vscode, search and install `ms-vscode-remote.remote-containers`
2. `Ctrl + Shift + p`, type `Dev Container: Open Folder in Container` then select current project folder. This action creates a Dev Container image and container.
    - The container and images would be listed on docker-desktop if it is installed.

### Connect to the Dev Container on Vscode 
1. Click on `Remote Explorer` on left sidebar in Vscode 
2. Select on `Dev Container` on the top of Menu Bar

	![](/assets/img/2023-09-25/dev_container_vscode1.png)

3. Choose the current project container and click on `->` to connect it 
    - This opens a new Vscode window that operates within the Dev Container

	![](/assets/img/2023-09-25/dev_container_vscode2.png)

4. For rebuilding the container from this image, click on `Run interactive` on the image on `Dev Images` panel 

	![](/assets/img/2023-09-25/dev_container_vscode3.png)

## Common Mistakes 
It's important to note that using docker build to create a Docker image, and then attempting to connect it under Dev Container in Vscode, may result in connection failures. Docker and Dev Containers are separate entities and **cannot directly access each other's systems**.

## Running Code on Dev Container 
1. On the new Vscode window, `ctrl + r` would pop up a terminal on vscode for running scripts inside the container   
2. Any modification on dev container would be synced up with the project locally 
    - Git action can either be run on terminal or local  

For details on training and API setup, you can refer to the instructions in **Sports Gesture Classification - Part1 Docker**.


Thank you for your attention and happy coding!