#Connect to the swarm manager
eval $(docker-machine env swarm-manager1)

#Create MySQL Root Password, available to containers at /run/secrets/mysql_root_password
openssl rand -base64 64 | docker secret create mysql_root_password -

#Create MySQL App Passsword, available to containers at /run/secrets/mysql_app_password
openssl rand -base64 64 | docker secret create mysql_app_password -

#Show all our secrets
docker secret ls