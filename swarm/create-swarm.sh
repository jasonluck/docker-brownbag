#Create 3 nodes for our swarm. One manager and two workers.
docker-machine create --driver virtualbox swarm-manager
docker-machine create --driver virtualbox swarm-node1
docker-machine create --driver virtualbox swarm-node2

#Connect to the manager node and initialize our swarm
export MANAGER_IP="$(docker-machine ip swarm-manager)"
docker-machine ssh swarm-manager "docker swarm init --advertise-addr $MANAGER_IP"

#Save the swarm token so we can join our worker nodes
export SWARM_TOKEN=$(docker-machine ssh swarm-manager "docker swarm join-token -q worker")

#Join our worker nodes to the swarm
docker-machine ssh swarm-node1 "docker swarm join --token $SWARM_TOKEN $MANAGER_IP:2377"
docker-machine ssh swarm-node2 "docker swarm join --token $SWARM_TOKEN $MANAGER_IP:2377"

#Connect to the swarm manager
eval $(docker-machine env swarm-manager)

#Deploy some container monitoring services
docker service create \
  --name=viz \
  --publish=8080:8080/tcp \
  --constraint=node.role==manager \
  --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
  manomarks/visualizer

#Show our swarm nodes
docker-machine ssh swarm-manager "docker node ls"

echo ''
echo ''
echo '---------- Swarm is Ready ----------------'
echo ''
echo "Visualizer is available at http://${MANAGER_IP}:8080"
echo ''
echo 'Run this command to configure your shell:'
echo ''
echo '      eval $(docker-machine env swarm-manager)'
echo ''