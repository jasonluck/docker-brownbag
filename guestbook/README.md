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