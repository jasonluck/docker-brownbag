# Docker Brownbag - Docker in Production

## Overview of Swarm Mode

## Create a swarm

## Application Deployment

### Rolling Update

## Security

## Monitoring Containers

### Logging

### Health Checks

## Volumes and Data Backup

## Demo
Configure our docker client to talk to the swarm manager by running:
```
docker-machine env swarm-manager;
eval $(docker-machine env swarm-manager)
```

After configuring our client to talk to the swarm, to deploy our app to the swarm run:
```
docker stack deploy -c docker-compose.yml guestbook
```