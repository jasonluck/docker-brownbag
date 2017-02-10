# Docker Brownbag - Deploying your Application Stack
Deploying our application locally is one thing, but for Production deployments we need more than a single node architecture. For
a high-availablity architecture, __Docker Swarm Mode__ is what we need.

## Overview of Swarm Mode
Docker Swarm mode creates a "swarm" of Docker engines  across multiple physical or virtual nodes. Swarms provide a clustered environment to deploy your 
containers to that supports dynamic-service discovery, load balancing, scaling and state reconciliation out of the box.

### Nodes 
Swarms are comprised of multiple __nodes__. A node is an instance of the Docker engine wich participates in the swarm. Nodes can have one of two roles:
* `Manager node` - Managers perform the orchestration and cluster management for the swarm. __Service definitions__ are submitted to a manager node. The manager node
then dispatches __tasks__ to the worker nodes.
* `Worker node` - Workers execute __tasks__ dispatched to it from Manager nodes. The worker communicates the state of those tasks back to the manager.

### Services and tasks
Services are the definitions of the container image to run and the comand within that image to execute. The service also defines how to scale that
container across the swarm. Two replication models are supported:
* Replicated Services - Specify the number of instances to deploy across the swarm
* Global Services - Exactly one instance of the container runs on every available node in the swarm.

Service Example:
```
docker service create \
  --name=viz \
  --publish=8080:8080/tcp \
  --constraint=node.role==manager \
  --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
  manomarks/visualizer
```

Tasks are the atomic units of work in the swarm. They contain the conatiner and command for the assigned to node to execute. 
Tasks can only be run by their assinged node.

### Load Balancing
Swarm uses Ingress Load balancing to expose services you want to make available external to the swarm. The specified published service port is available on any
node in the swarm, whether that node is running the service or not. The swarm handles routing the traffic to the correct node. 

Swarm mode has an internal DNS component that automatically assigns each service in the swarm a DNS entry. The swarm manager uses internal load balancing
 to distribute requests among services within the cluster based upon the DNS name of the service.

## Create a swarm

## Application Deployment

### Rolling Update

## Security

## Monitoring Containers

### Logging

### Health Checks

## Volumes and Data Backup

## Demo