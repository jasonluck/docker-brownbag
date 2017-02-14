## Getting started
Download [Docker](https://www.docker.com/products/overview). If you are on Mac or Windows, [Docker Compose](https://docs.docker.com/compose) will be automatically installed. On Linux, make sure you have the latest version of [Compose](https://docs.docker.com/compose/install/).

Download [Virtual Box](https://www.virtualbox.org/wiki/Downloads). This will be used by `docker-machine` to create multiple docker nodes for our swarm.

## Create our swarm
Our swarm is going to consist of 2 manager nodes and 3 worker nodes. We are also going to install a visualization service to allow us to easily 
see which containers are running on which nodes.

To create our swarm run:
```
./create-swarm.sh
```

### Deploy our application stack
Configure our docker client to talk to the swarm manager by running:
```
docker-machine env swarm-manager1;
eval $(docker-machine env swarm-manager1)
```

After configuring our client to talk to the swarm, to deploy our app to the swarm run:
```
docker stack deploy -c docker-compose.yml guestbook
```

### Rolling Update
Monitor the services status
```
curl -s -L -o /dev/null -w "%{http_code}\n" http://192.168.99.100/services
```

Apply the Update
```
docker service update \
     --update-parallelism 1 \
     --update-delay 30s \
     --image jluck/brownbag-guest-service:1.0.1 \
     guestbook_rest-services
```