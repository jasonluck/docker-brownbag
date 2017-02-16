#!/bin/bash

#Connect to the swarm
eval $(docker-machine env swarm-manager1)

#Create MySQL Root Password, available to containers at /run/secrets/mysql_root_password
openssl rand -base64 64 | docker secret create mysql_root_password -

#Create MySQL App Passsword, available to containers at /run/secrets/mysql_app_password
openssl rand -base64 64 | docker secret create mysql_app_password -

#Create our networks
docker network create -d overlay backend
docker network create -d overlay frontend

#Deploy MySQL DB
docker service create \
    --name app-db \
    --network backend \
    --secret mysql_root_password \
    --secret mysql_app_password \
    --env MYSQL_DATABASE=app \
    --env MYSQL_USER=appuser \
    --env MYSQL_ROOT_PASSWORD_FILE=/run/secrets/mysql_root_password \
    --env MYSQL_PASSWORD_FILE=/run/secrets/mysql_app_password \
    --constraint 'node.role == worker' \
    --label app.stack=guestbook \
    mysql

#Deploy our app schema
docker service create \
    --name app-db-schema \
    --network backend \
    --secret mysql_app_password \
    --env DB_HOST=app-db \
    --env DB_DATABASE=app \
    --env DB_USER=appuser \
    --env DB_PASSWORD_FILE=/run/secrets/mysql_app_password \
    --constraint 'node.role == worker' \
    --restart-condition none \
    --label app.stack=guestbook \
    jluck/brownbag-db:1.0

#Deploy our rest services
docker service create \
    --name rest-services \
    --network backend\
    --network frontend \
    --secret mysql_app_password \
    --env DB_HOST=app-db \
    --env DB_DATABASE=app \
    --env DB_USER=appuser \
    --env DB_PASSWORD_FILE=/run/secrets/mysql_app_password \
    --constraint 'node.role == worker' \
    --replicas 2 \
    --update-parallelism 1 \
    --update-delay 1m \
    --update-monitor 20s  \
    --label app.stack=guestbook \
    -p 8081:80 \
    jluck/brownbag-guest-service:1.0.1

#Deploy our web server
docker service create \
    --name web \
    --network frontend \
    --constraint 'node.role == worker' \
    --replicas 3 \
    --update-parallelism 1 \
    --update-delay 1m \
    --update-monitor 20s  \
    --label app.stack=guestbook \
    -p 80:80 \
    jluck/brownbag-web:1.0

#Show all our secrets
docker secret ls

#Print out all our services
docker service ls