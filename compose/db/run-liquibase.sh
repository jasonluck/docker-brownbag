#!/bin/bash

export LIQUIBASE_HOME=/opt/liquibase
export DB_URL=jdbc:mysql://${DB_HOST}:${DB_PORT}/${DB_DATABASE}

$LIQUIBASE_HOME/liquibase \
	--driver=com.mysql.jdbc.Driver \
	--url=$DB_URL \
	--username=$DB_USER \
	--password=$DB_PASSWORD \
	--changeLogFile=$CHANGELOG \
	$@