# Intro to Docker

## What is Docker?
Docker is a tool that builds a "container" that contains everything needed to run your application. This includes
your code deployment, runtime, system tool and system libraries; anything that would be installed on your server. The goal of
the tool is to provide a configuration controlled, deployable artifact that can be guaranteed to run the same, no matter where
it is deployed.


### What are containers?
Containers run on a single machine and share the same OS kernel. Container images are constructed using a layered
filesystem and share common files. This makes the image disk space much more efficient, which means your image file sizes
quite small and quick to download.

How are they different from VMs?
![VM Architecture](https://www.docker.com/sites/default/files/WhatIsDocker_2_VMs_0-2_2.png) ![Container Architecture](https://www.docker.com/sites/default/files/WhatIsDocker_3_Containers_2_0.png)

## Why would I want to use Docker?

## Developer Use Cases

## Production Use Cases

## Additional Resources
* [Brown Bag Presentation - https://github.com/jasonluck/docker-brownbag](https://github.com/jasonluck/docker-brownbag)
* [Docker Documentation - https://docs.docker.com/](https://docs.docker.com/)