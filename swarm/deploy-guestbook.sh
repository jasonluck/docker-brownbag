#!/bin/bash

#Connect to the swarm
eval $(docker-machine env swarm-manager1)

#Create MySQL Root Password, available to containers at /run/secrets/mysql_root_password
openssl rand -base64 64 | docker secret create mysql_root_password -

#Create MySQL App Passsword, available to containers at /run/secrets/mysql_app_password
openssl rand -base64 64 | docker secret create mysql_app_password -

#Show all our secrets
docker secret ls

#Create our networks
docker network create -d overlay guestbook_backend;
docker network create -d overlay guestbook_frontend

#Deploy MySQL DB
docker service create \
    --name guestbook_app-db \
    --network guestbook_backend \
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
    --name guestbook_app-db-schema \
    --network guestbook_backend \
    --secret mysql_app_password \
    --env DB_HOST=guestbook_app-db \
    --env DB_DATABASE=app \
    --env DB_USER=appuser \
    --env DB_PASSWORD_FILE=/run/secrets/mysql_app_password \
    --constraint 'node.role == worker' \
    --restart-condition none \
    --label app.stack=guestbook \
    jluck/brownbag-db:1.0

#Deploy our rest services
docker service create \
    --name guestbook_guest-service \
    --hostname rest-services \
    --network guestbook_backend \
    --network guestbook_frontend \
    --secret mysql_app_password \
    --env DB_HOST=guestbook_app-db \
    --env DB_DATABASE=app \
    --env DB_USER=appuser \
    --env DB_PASSWORD_FILE=/run/secrets/mysql_app_password \
    --constraint 'node.role == worker' \
    --replicas 2 \
    --update-parallelism 1 \
    --update-delay 2m \
    --update-monitor 1m  \
    --label app.stack=guestbook \
    -p 8081:80 \
    jluck/brownbag-guest-service:1.0.1