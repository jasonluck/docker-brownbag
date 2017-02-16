#!/bin/bash

#Connect to the swarm
eval $(docker-machine env swarm-manager1)

#Remove our services
docker service rm web rest-services app-db-schema app-db

#Remove our networks
docker network rm frontend backend

#Remove our secrets
docker secret rm mysql_root_password mysql_app_password