# Hands on with Guestbook app
The guestbook app is just a simple 3-tier web application stack, which is defined in a [docker-compose.yml](docker-compose.yml) file. It is comprised of
a Nginx web server hosting the application static content, a REST service which communicates with a MySQL server for data persistence.

![Application Architecture](architecture.png)

##Getting started
Download [Docker](https://www.docker.com/products/overview). If you are on Mac or Windows, [Docker Compose](https://docs.docker.com/compose) will be automatically installed. On Linux, make sure you have the latest version of [Compose](https://docs.docker.com/compose/install/).

## Building the app
Start by compiling the `go` rest service:
```
GOOS=linux bash build
```
## Build and start the containers
When `docker-compose up` is executed, Docker will build any images that need to be built
before the containers are started.
```
docker-compose up -d
```
After the containers are started the application is available at `http://localhost`