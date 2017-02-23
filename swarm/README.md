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
To create our application we need to create our set of secrets, setup our networks and define our services. I have placed all those commands
into the [deploy-guestbook.sh](deploy-guestbook.sh) script. So to deploy our app, all we need to run is:
```bash
./deploy-guestbook.sh
```

### Rolling Update
Monitor the services status
```bash
while (true) do \
    curl -s -L -w ":%{http_code}\n" http://192.168.99.100:8081/version;
    sleep 1;
done
```

Apply the update to a newer version of the container image
```bash
docker service update --image jluck/brownbag-guest-service:1.0.2 rest-services
```


### Centralize Logging
Deploy our ELK stack to the swarm. Logstash runs on each node to capture logging and forward to ElasticSearch.

```bash
docker stack deploy -c logging/docker-compose.yml logging
```

Rolling update to all our containers to change thier logging setup to send logs to LogStash
```bash
for SERVICE in $(docker service ls --filter "label=app.stack=guestbook" -q)
do
    docker service update --log-driver gelf --log-opt gelf-address=udp://localhost:12201 $SERVICE
done
```

Hit the guestbook app a few times and we can see that our logs are now all being collected at http://192.168.99.100:5601/