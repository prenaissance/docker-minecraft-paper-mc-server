#!/bin/sh
set -e

DOCKER_USER='dockeruser'
DOCKER_GROUP='dockergroup'

if ! id "$DOCKER_USER" >/dev/null 2>&1; then
	echo "First start of the docker container, start initialization process."

	UID=${PUID:-1000}
	GID=${PGID:-1000}
	echo "Starting with $UID:$GID (UID:GID)"

	addgroup --gid $GID $DOCKER_GROUP
	adduser $DOCKER_USER --shell /bin/sh --uid $UID --ingroup $DOCKER_GROUP --disabled-password --gecos ""

	chown -vR $UID:$GID /opt/minecraft
	chmod -vR ug+rwx /opt/minecraft

	if [ "$SKIP_PERM_CHECK" != "true" ]; then
		chown -vR $UID:$GID /data
	fi
fi

export HOME=/home/$DOCKER_USER
exec gosu $DOCKER_USER:$DOCKER_GROUP java -jar -Xms$INIT_MEMORY -Xmx$MAX_MEMORY $JAVAFLAGS /opt/minecraft/paperspigot.jar $PAPERMC_FLAGS nogui
