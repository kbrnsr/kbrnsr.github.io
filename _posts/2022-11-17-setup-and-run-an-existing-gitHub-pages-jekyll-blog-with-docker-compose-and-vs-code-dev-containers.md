---
layout: post
title:  "Setup and run an existing GitHub Pages Jekyll blog with Docker Compose and VS Code Dev Containers"
date:   2022-11-17 14:13:00 +0200
categories: vscode docker-compose docker ruby jekyll github github-pages
---

The motivation for writing this guide is mainly because this is a blog and I have no posts.
No, what I hope is that someone, someday, will be searching for some random issue, end up here, and go home with a solution to their problem, exactly like I have done with so many random sites.
I won't be describing how to set up the blog itself and the necessary configuration for it, but the whole blog, with all the bells and whistles, is available on [kbrnsr/kbrnsr.github.io][kbrnsr/kbrnsr.github.io] for your perusal.

## Table of contents
- [Prerequisites](#prerequisites)
- [Initial setup](#initial-setup)
- [Environment file](#environment-file)
- [VS Code](#vs-code)
- [Docker Compose](#docker-compose)
- [Conclusion](#conclusion)

## Prerequisites

- VS Code v1.73.1.
- Docker v20.10.21.
- Docker Compose v2.12.2.
- VS Code Dev Containers extension (ms-vscode-remote.remote-containers) v0.262.3.
- VS Code setup with https for git repositories.
- A properly configured GitHub Pages blog.
- (Optional) Docker Desktop v4.14.1.
- (Optional) VS Code Dev Containers extension setup with dotfiles repository.

## Initial setup

![vscode-dev-containers-add-dev-container-configuration-files](/assets/videos/vscode-dev-containers-add-dev-container-configuration-files.webp)

I recommend running the `Dev Containers: Add Dev Container Configuration Files` wizard to auto-magically create all the necessary files or continue to the next step if you already have your project set up.
If you're still reading this part, then remember to choose an option that starts multiple services. For example `Ruby on Rails & Postgres`. This will serve as an excellent starting point for further customization.

## Environment file
The env file for Docker Compose needs to be in the project root.
Why?
Well, the default behavior for Compose is to pick up the `.env` file from the same folder as it's defined in, but this won't work with the Dev Containers extension, which wants to pick it up from the `.devcontainer` folder or in the worst case the local workspace folder root.
It will **not** pick it up if defined in any other folder.

Create the file `.env` in the project root:

```Shell
COMPOSE_PROJECT_NAME=kbrnsr.github.io
CONTAINER_WORKSPACE_FOLDER=/workspaces/github
RUBY_VERSION=3.1.2
```

-	`COMPOSE_PROJECT_NAME` should be the same as the project folder name since it is used later in the Compose file.
It is especially useful if you have multiple services in Compose since every service container will be prepended with this name. In Docker Desktop it will group every service container under this name.
-	`CONTAINER_WORKSPACE_FOLDER` is the folder in which the project's parent folder will be mounted.
My definition is a little special since I have a customized git setup.
-	`RUBY_VERSION` is very straightforward, just set it to the Ruby version you want to use.

## VS Code

Create the file `.devcontainer/devcontainer.json` in your project root with the following content:

```json
{
	"name": "kbrnsr.github.io",
	"dockerComposeFile": "../docker-compose.yaml",
	"service": "app",
	"workspaceFolder": "/workspaces/github/${localWorkspaceFolderBasename}",
	"shutdownAction": "stopCompose",
	"postStartCommand": "git config --global --add safe.directory ${containerWorkspaceFolder} && bundle exec jekyll serve --watch --force_polling --verbose --livereload bundler exec jekyll serve --livereload --host 0.0.0.0"
}
```

- `name` is used only internally by VS Code GUI, this can be set up to whatever your heart desires.
- `dockerComposeFile` should be the location of your Docker Compose file relative to the `.devcontainer` folder.
In my case it's in the project root, note that the extension for the Compose file is `.yaml` and not `.yml`.
- `service` depends on the `services` defined in the Compose file, choose the service you want to use to start up as a dev container.
-	`workspaceFolder` is the workspace folder inside the container.
I have defined it as `/workspaces/github/${localWorkspaceFolderBasename}`, where `/workspaces/github` is the same as `CONTAINER_WORKSPACE_FOLDER` in the environment file and `${localWorkspaceFolderBasename}` is the workspace folder name on the local filesystem.
-	`shutdownAction` is what VS Code is supposed to do when it exits or in any other situation where the dev container needs to stop.
Here it will stop Compose.
-	`postStartCommand` defines what the dev container will do after starting.
In my case, I need to run a command to make git understand that the container workspace folder is okay to work with as well as startup the Jekyll live server.
The host for the live server needs to be `0.0.0.0` or it won't work properly.

## Docker Compose

Create the file `docker-compose.yaml` in your project root with the following content:

```YAML
version: '3.8'
services:
  app:
    build:
      context: .
      dockerfile: .docker/Dockerfile
      args:
        - RUBY_VERSION
    ports:
      - "127.0.0.1:4000:4000"
      - "127.0.0.1:35729:35729"
    volumes:
      - ./.:${CONTAINER_WORKSPACE_FOLDER}/${COMPOSE_PROJECT_NAME}:cached
    working_dir: ${CONTAINER_WORKSPACE_FOLDER}/${COMPOSE_PROJECT_NAME}
    # Overrides default command so things don't shut down after the process ends.
    command: sleep infinity
```

As mentioned earlier, the dev container configuration will use the service `app` so this will be the part covered here.
It doesn't use any predefined docker image ergo it needs to be built.

- `context` is the location the docker build process will use relative to the Compose file.
-	`dockerfile` is the Dockerfile to be used relative to the compose file.
- `args` here will send arguments down to the Dockerfile during the build process, here it will send `RUBY_VERSION` as defined in the environment file.
- `ports` will publish ports `4000` and `35729` from inside the container to the local system, without these ports you won't be able to connect to the Jekyll live server in case you wish to use Docker Compose outside of VS Code.
- `volumes` will map the folder `./.` to `${CONTAINER_WORKSPACE_FOLDER}/${COMPOSE_PROJECT_NAME}` where the variables are defined in the environment file.
This part can be really useful if you for example had a node project and wanted to put `node_modules` in a separate volume to increase performance.
- `working_dir` is the default container folder to use whenever we run a command.
- `command` is the command to run after startup, to make sure it doesn't get closed automatically it should be set to `sleep infinity`.

## Conclusion

There are of course many ways to skin a cat, but this is my way.  
It might not necessarily be the best method, but if you've reached this point, and find something unclear then do send me an email.
If there's something that can be improved upon, then fork the blog repository, change anything you want and send me a pull request.

One of the things I could have improved, but haven't taken the time to implement is making the whole project work with only Docker Compose.
This would have been useful if I ever decided to switch over from VS Code to another integrated development environment.

[kbrnsr/kbrnsr.github.io]: https://github.com/kbrnsr/kbrnsr.github.io