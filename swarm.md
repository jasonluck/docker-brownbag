# Docker Brownbag - Deploying your Application Stack
Deploying our application locally is one thing, but for Production deployments we need more than a single node architecture. For
a high-availablity architecture, __Docker Swarm Mode__ is what we need.

## Overview of Swarm Mode
Docker Swarm mode creates a "swarm" of Docker engines  across multiple physical or virtual nodes. Swarms provide a clustered environment to deploy your 
containers to that supports dynamic-service discovery, load balancing, scaling and state reconciliation out of the box.

### Nodes 
Swarms are comprised of multiple __nodes__. A node is an instance of the Docker engine wich participates in the swarm. Nodes can have one of two roles:
* `Manager node` - Managers perform the orchestration and cluster management for the swarm. __Service definitions__ are submitted to a manager node. The manager node
then dispatches __tasks__ to the worker nodes. Manager nodes store the state of the swarm and replicate this state between manager nodes
using a [Raft Consensus](http://thesecretlivesofdata.com/raft/) algorithm.
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
To create a swarm, you first need to create our first manager node. If you are not using docker-machine to create your nodes, then you will
need to supply the IP address of your manager node.
```bash
export MANAGER_IP="$(docker-machine ip swarm-manager1)"
docker swarm init --advertise-addr $MANAGER_IP
```

When the swarm is initialized, a swarm token will be created and displayed in the output of the command. This token is used to join nodes to the swarm.
```
To add a worker to this swarm, run the following command:

    docker swarm join \
    --token SWMTKN-1-49nj1cmql0jkz5s954yi3oex3nedyz0fb0xx14ie39trti4wxv-8vxv8rssmk743ojnwacrr2e7c \
    $MANAGER_IP:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.
```

To see all the nodes in our swarm we can run the `docker node ls` command:
```
$ docker node ls

ID                           HOSTNAME  STATUS  AVAILABILITY  MANAGER STATUS
dxn1zf6l61qsb1josjja83ngz *  manager1  Ready   Active        Leader
```

## Application Deployment

### Rolling Update

## Security

## Monitoring Containers

### Logging
The `docker logs` command shows the command's output as it would appear if you ran it from the command line. On UNIX/Linux this means any output to
STDOUT and STDERR. In some cases however the ouput of the `docker logs` command my not be helpful:
* If your containers process logs information to a log file instead of STDOUT or STDERR.
* If you use a logging driver that sends logs to a file or a remote system/service.

Docker offer a large number of logging drivers that can be configured for your container. A complete list of supported drivers are available [here](https://docs.docker.com/engine/admin/logging/overview/),
but some examples include __syslog__, __AWS Cloudwatch Logs__, __LogStash__, and __Google Cloud Platform Logging__.

### Health Checks
New with Docker 1.12 is the ability to add a health check into your container. This allows docker to query the health of your containerized application.
If your container doesn't have a healthcheck configured, you can configure one in the service definition. After the health check fails more than the
defined number of retries, the container is considered to be failed and the container will be stopped and a new container started.

__Health Check added to Container Image__
```Dockerfile
HEALTHCHECK --interval=30s --timeout=10s CMD curl --fail http://localhost/healthz || exit 1
```

__Health Check defined in Service Definition__
```bash
docker run -d \
  --health-cmd='url --fail http://localhost || exit 1' \
  --health-interval=30s \
  --health-timeout=10s \
  --health-retries=2 \
  nginix
```

## Volumes and Data Backup

## Demo