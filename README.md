# Docker From Scratch

## Why Docker

Perhaps you have heard docker explained as: "Docker helps make code run on every machine the same".

Though there are some nuances, this is essentially the purpose of Docker, more specifically **Containers**.

## Core Concepts

With Docker, almost everything revolves around **Images** and **Containers**.

There are other concepts which offer further enhancements, such as volumes and networks, but for you to appreciate those things you first must understand **Containers**.

### Images

A Docker **Image** is simply a file that contains a series of immutable "layers" built atop one another to create a final layer in which is used for instantiating a **Container**.

The base layer is either an operating system (99.99% of the time, a Linux distro) or *Scratch*.

*Scratch* is a special layer that only provides only a file system, therefore only suitable for housing a binary that can be ran standalone (ex. a Go executable).

### Containers

Containers can be thought of as lightweight virtual machines.

They are the instantiation of an **Image**, a process that is running in the Docker "runtime".

They can be either Running or Stopped.

They can be interacted will similar to processes on your own machine through the Docker Command Line Interface and SDK.

You can list, stop & remove, build, run, and execute commands in **Containers** all from the command line on your host machine.

## Building **Images**

An **Image** is a series of layers, we can create an **Image** with these layers by building one.

A `Dockerfile` is the blueprint laying out how the layers in an **Image** are put together.

The official Dockerfile format is layed out in this reference [https://docs.docker.com/engine/reference/builder/](https://docs.docker.com/engine/reference/builder/).

This is the `Dockerfile` we will be analyzing and working with:

```dockerfile
FROM alpine:latest

COPY test.txt .

RUN cat test.txt

RUN echo I can have multiple commands in one RUN build step by && \
        echo stringing commands togethor with '&&' to continue executing && \
        echo commands if the previous command succeeded without an error code && \
        echo and '\\' to escape the line break in the Dockerfile so you can have && \
        echo more than one line to put your commands on

CMD ["echo", "HI THERE!"]
```

A `Dockerfile` has 3 main components:

1. The Base **Image**

    ```dockerfile
    FROM alpine:latest
    ```

    This states that we want to build off of the alpine **Image**, one of the smallest, most minimal linux distributions.

2. The Core Build Steps

    ```dockerfile
    COPY test.txt .

    RUN cat test.txt

    RUN echo I can have multiple commands in one RUN build step by && \
           echo stringing commands togethor with '&&' to continue executing && \
           echo commands if the previous command succeeded without an error code && \
           echo and '\\' to escape the line break in the Dockerfile so you can have && \
           echo more than one line to put your commands on
    ```

    These are the steps that will be executed to build your **Image**

    `COPY` - Copies from the directory your Dockerfile is in to the image.

    `RUN` - Runs a command in the image, must be a command available in the image. For example, you can't run `cat` if it's not in the **Image**.

    Other notable Build Step directives not shown here:

    `ARG` - Set an environmental variable in the **Image** and thus, eventually, the **Container**

    `USER` - Change the user to operate in the **Image** as (if user is not changed before **Container** is ran, then it is used for the **Container**)

    WARNING:

    `ADD` - Similar to copy, but WILL NOT EVER CACHE, has some extra functionality that is specified [here](https://nickjanetakis.com/blog/docker-tip-2-the-difference-between-copy-and-add-in-a-dockerile).

3. A Command or Final Entrypoint (OPTIONAL, but almost always included)

    ```dockerfile
    CMD ["echo", "HI THERE!"]
    ```

    `CMD` - Specifies the command that will be executed when the **Image** is instantiated as a **Container** with `docker run`. If you specify a command to execute after `docker run`, like: `docker run {IMAGE NAME} echo test`, then the command on the command line will overwrite what was specified in the Dockerfile.

    Alternatively:

    ```dockerfile
    ENTRYPOINT ["echo", "HI THERE!"]
    ```

    `ENTRYPOINT` - Just like `CMD`, this specifies the command that will be executed when the **Image** is instantiated as a **Container** with `docker run`. However, unlike `CMD` you cannot  specify a command to execute after `docker run`.

```sh
$ docker build -t test:latest .
Sending build context to Docker daemon  11.26kB
Step 1/5 : FROM alpine:latest
 ---> 3f53bb00af94
Step 2/5 : COPY test.txt .
 ---> Using cache
 ---> 711b165f55ab
Step 3/5 : RUN cat test.txt
 ---> Using cache
 ---> 910da957528e
Step 4/5 : RUN echo I can have multiple commands in one RUN build step by &&         echo stringing commands togethor with '&&' to continue executing &&         echo commands if the previous command succeeded without an error code &&         echo and '\\' to escape the line break in the Dockerfile so you can have &&         echo more than one line to put your commands on
 ---> Running in 15192fd14cff
I can have multiple commands in one RUN build step by
stringing commands togethor with && to continue executing
commands if the previous command succeeded without an error code
and \\ to escape the line break in the Dockerfile so you can have
more than one line to put your commands on
Removing intermediate container 15192fd14cff
 ---> d201427663e4
Step 5/5 : CMD ["echo", "HI THERE!"]
 ---> Running in 29e62e875eaf
Removing intermediate container 29e62e875eaf
 ---> 810b5505a12a
Successfully built 810b5505a12a
Successfully tagged test:latest
SECURITY WARNING: You are building a Docker image from Windows against a non-Windows Docker host. All files and directories added to build context will have '-rwxr-xr-x' permissions. It is recommended to double check and reset permissions for sensitive files and directories.
```

The `-t` flag tags an image so we can run it by the tag later.

If `:latest` isn't specified and only a name is given `test` then it will be given the `:latest` tag.

So even if you didn't build with `-t test:latest`, and instead just did `-t test`, you would end up with the same result.

In the same vein, if you want to run the image and it has the tag `test:latest`, you can run it with either `docker run test` or `docker run test:latest`; meaning that if you run without a tag, it will default to `:latest`.

The image has the tag `test:latest`, you can run it by doing:

```sh
$ docker run test:latest
HI THERE!
```


## Interaction with containers

Because containers are actively running, they can be interacted with similar to a process on your system through the Docker Command Line Interface and SDK.

### Listing Containers

```sh
$ docker ps
CONTAINER ID        IMAGE                      COMMAND                  CREATED             STATUS              PORTS                                      NAMES
f3c0e3e570cd        nginx                      "nginx -g 'daemon of…"   10 seconds ago      Up 8 seconds        0.0.0.0:8800->80/tcp                       my-nginx
```

From here you can leverage this information for use in other commands.

There are flags on this command to do other things like show stopped containers (`-a`).

### Stopping and Removing Containers

```sh
$ docker ps
CONTAINER ID        IMAGE                      COMMAND                  CREATED             STATUS              PORTS                                      NAMES
f3c0e3e570cd        nginx                      "nginx -g 'daemon of…"   10 seconds ago      Up 8 seconds        0.0.0.0:8800->80/tcp                       my-nginx
$ docker stop f3c0e3e570cd
f3c0e3e570cd
## Removing a Stopped container, you could start it again with `docker start {container ID or NAME}` also
$ docker rm f3c0e3e570cd
f3c0e3e570cd
```

### Starting a Stopped **Container**

This will run the container again from the point where it left off.

```sh
$ docker ps -a
CONTAINER ID        IMAGE                      COMMAND                  CREATED             STATUS              PORTS                                      NAMES
f3c0e3e570cd        nginx                      "nginx -g 'daemon of…"   27 minutes ago      Exited (0) About a minute ago                                    my-nginx
$ docker start f3c0e3e570cd
f3c0e3e570cd
```

### Creating a **Container**

Again a **Container** is the instantiation of an **Image**.

Therefore you can create a **Container** from **Image**s available on your machine or remotely because an **Image** is simply a file that contain a series of layers.

If you don't have an **Image** locally, by default Docker will search for the **Image** on the [Docker hub](https://hub.docker.com/).

```sh
$ docker run --name some-nginx -p 8800:80 nginx
# Then, if you access http://localhost:8800 on your web browser
172.17.0.1 - - [15/Feb/2020:20:32:55 +0000] "GET /test.html HTTP/1.1" 200 25 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.130 Safari/537.36" "-"
```

Alternatively, you can run the **Container** with the `-d` flag to run it in "daemon" mode, meaning your won't be attached to the container.

```sh
$ docker run --name some-nginx -d -p 8800:80 nginx
```

### Executing commands in a **Container**

On shelling into a container:

If a container has a shell in the environment that it is in, you can get a shell in it and interact with the container's runtime.

For example, running an Nginx **Image** and therefore starting an Nginx **Container**:

(from: [https://hub.docker.com/_/nginx](https://hub.docker.com/_/nginx))

```sh
$ docker run --name some-nginx -p 8800:80 nginx
```

Then in a separate shell, we create a shell by executing `sh` in the **Container**:

Alternatively, if you run the container with the `-d` flag, you can just keeping doing this from the shell you were already in (duh).

```sh
$ docker ps
CONTAINER ID        IMAGE                      COMMAND                  CREATED             STATUS              PORTS                                      NAMES
f3c0e3e570cd        nginx                      "nginx -g 'daemon of…"   10 seconds ago      Up 8 seconds        0.0.0.0:8800->80/tcp                       my-nginx

# Two ways, either using the Container ID, or the container name
$ docker exec -it f3c0e3e570cd sh
# OR
$ docker exec -it my-nginx sh

# Note, that you'll see the prompt "# ", but for the sake of illustating that here where it would be interpreted as a comment in the Markdown, we'll use "$$ " in place of "# "

$$ ls
bin  boot  dev  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var

$$ cd /usr/share/nginx/html
$$ ls
50x.html  index.html

$$ echo this is a test html file > test.html
$$ ls
50x.html  index.html  test.html
```

Then go to [http://localhost:8800/test.html](http://localhost:8800/test.html) and you will see the page you just created.

## Docker-Compose

### Why

Docker-Compose is a higher level abstraction for many of the "lower level" Docker commands.

It's main purpose is to simplify many of the tasks that you would need to do in order to set up a development environment.

### Core Concepts

#### `docker-compose.yml`

This file sets up the configuration for your environment and provides references (context) to the `docker-compose` command to interact with the services in your environment.

It's written in a hierarchical structure; if it seems familiar, it's because YAML is a superset of JSON.

You can find the reference for version 3 (the latest and one I would recommend) here: [https://docs.docker.com/compose/compose-file/](https://docs.docker.com/compose/compose-file/)


### Common Commands

#### `docker-compose up`

Brings up all services specified in the `docker-compose.yml` file.

You can specify specific services to bring up by naming them afterwards, example:

`docker-compose up service1 service2`

#### `docker-compose build`

Builds the **Images** for all services in `docker-compose.yml`.

Like with `docker-compose up` you can specify specific services to build.

#### `docker-compose down`

Stops and removes running **Containers** for the services specified in `docker-compose.yml`.

Unlike with `docker-compose up` you cannot specify specific services, it's all or nothing.

However, if you want to bring down specific services, you can use `docker ps` to find the services and `docker stop` then `docker rm` to remove the **Containers** for the services.

If you would like to replace a running **Container** for a service with a newer version that has been built with `docker-compose build`, executing `docker-compose up` again will replace older versions of services with their newer versions.