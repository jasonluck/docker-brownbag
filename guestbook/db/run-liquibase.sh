#!/bin/bash

export LIQUIBASE_HOME=/opt/liquibase
export DB_URL=jdbc:mysql://${DB_HOST}:${DB_PORT}/${DB_DATABASE}
export DB_NOT_READY="true"

if [ ! -z "${DB_PASSWORD_FILE}" ]; then
	echo "Using database password specified in $DB_PASSWORD_FILE"
	DB_PASSWORD=`cat $DB_PASSWORD_FILE`
fi

while [ ! -z "${DB_NOT_READY}" ]
do
	echo "Waiting 5sec for DB to start..."
	sleep 5
	$LIQUIBASE_HOME/liquibase \
	--driver=com.mysql.jdbc.Driver \
	--url="$DB_URL" \
	--username="$DB_USER" \
	--password="$DB_PASSWORD" \
	--changeLogFile="$CHANGELOG" \
	listLocks > /tmp/db_ready 2>&1
	DB_NOT_READY=$(cat /tmp/db_ready | grep "Unexpected error running Liquibase: com.mysql.jdbc.exceptions.jdbc4.CommunicationsException: Communications link failure")
done

$LIQUIBASE_HOME/liquibase \
	--driver=com.mysql.jdbc.Driver \
	--url="$DB_URL" \
	--username="$DB_USER" \
	--password="$DB_PASSWORD" \
	--changeLogFile="$CHANGELOG" \
	$@