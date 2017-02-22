#Create 3 nodes for our swarm. One manager and two workers.
docker-machine create --driver virtualbox \
  --virtualbox-memory 2048 \
  swarm-manager1
docker-machine create --driver virtualbox \
  --virtualbox-memory 2048 \
  swarm-manager2
docker-machine create --driver virtualbox swarm-node1
docker-machine create --driver virtualbox swarm-node2
docker-machine create --driver virtualbox swarm-node3

#Connect to the manager node and initialize our swarm
export MANAGER_IP="$(docker-machine ip swarm-manager1)"
docker-machine ssh swarm-manager1 "docker swarm init --advertise-addr $MANAGER_IP"

#Save the swarm tokens so we can join our worker nodes
export WORKER_TOKEN=$(docker-machine ssh swarm-manager1 "docker swarm join-token -q worker")
export MANAGER_TOKEN=$(docker-machine ssh swarm-manager1 "docker swarm join-token -q manager")

#Join our worker nodes to the swarm
docker-machine ssh swarm-manager2 "docker swarm join --token $MANAGER_TOKEN $MANAGER_IP:2377"
docker-machine ssh swarm-node1 "docker swarm join --token $WORKER_TOKEN $MANAGER_IP:2377"
docker-machine ssh swarm-node2 "docker swarm join --token $WORKER_TOKEN $MANAGER_IP:2377"
docker-machine ssh swarm-node3 "docker swarm join --token $WORKER_TOKEN $MANAGER_IP:2377"

#Connect to the swarm manager
eval $(docker-machine env swarm-manager1)

#Deploy some container monitoring services
docker service create \
  --name=viz \
  --publish=8080:8080/tcp \
  --constraint=node.role==manager \
  --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
  manomarks/visualizer

#Show our swarm nodes
docker-machine ssh swarm-manager1 "docker node ls"

echo ''
echo ''
echo '---------- Swarm is Ready ----------------'
echo ''
echo "Visualizer is available at http://${MANAGER_IP}:8080"
echo ''
echo 'Run this command to configure your shell:'
echo ''
echo '      eval $(docker-machine env swarm-manager1)'
echo ''