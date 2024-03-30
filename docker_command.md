# Commands in setting up docker environment 
refer: https://jkindon.com/hydejack-github-pages-docker-containers/

## Aim 
Set up a container to render the initial Hydejack site locally


## Start docker on terminal 
```
systemctl --user start docker 
```

2. build image and start a container 
```
docker build -t blog .
docker run --name blog --mount src=/home/linlin/LL_Play/hydejack-starter-kit,target=/hydejack-starter-kitwebsite,type=bind \
 --mount src=/home/linlin/LL_Play/Veraz00,target=/Veraz00,type=bind \
 -p 4000:4000 -it blog bash
bundle exec jekyll serve --host 0.0.0.0 --incremental --watch --force_polling --strict_front_matter --drafts # in the container terminal 
```

## Stop the docker 
```
docker stop <docker container id>
```

## Restart docker 
```
docker start <docker container id>
docker exec -it <docker container id> bash 
```

- `-i` is `--interactive`: u can interact with the command that u run = when u type command, it gives reponse 
- `-t` is `--tty`: open a terminal 
- no need to add mount or port command when starting docker container again 


## Add another volume to current container 
```
docker commit <container id> <new image name> # create a new image with new image name from current container 
docker run --name <new container name> --mount src=/home/linlin/LL_Play/hydejack-starter-kit,target=/hydejack-starter-kitwebsite,type=bind \
 --mount src=/home/linlin/LL_Play/Veraz00,target=/Veraz00,type=bind \
 -p 4000:4000 -it <new image name> bash

```

# Error 
1. When launching the docker in local terminal, either starting docker-desktop, container or image, it would raise error: `docker-credential-desktop not installed or not available in PATH`
- Solution 

```
cat ~/.docker/config.json 
{
	"credStore": "desktop",
	"currentContext": "desktop-linux"
}

```
- !!note: it is "credStore", not "credsStore"	