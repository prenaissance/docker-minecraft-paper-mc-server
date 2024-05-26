#!/bin/sh
set -e

DOCKER_USER='dockeruser'
DOCKER_GROUP='dockergroup'

if ! id "$DOCKER_USER" >/dev/null 2>&1; then
	echo "First start of the docker container, start initialization process."

	UID=${PUID:-9001}
	GID=${PGID:-9001}
	echo "Starting with $UID:$GID (UID:GID)"

	addgroup --gid $GID $DOCKER_GROUP
	adduser $DOCKER_USER --shell /bin/sh --uid $UID --ingroup $DOCKER_GROUP --disabled-password --gecos ""

	chown -vR $UID:$GID /opt/minecraft
	chmod -vR ug+rwx /opt/minecraft

	if [ "$SKIP_PERM_CHECK" != "true" ]; then
		chown -vR $UID:$GID /data
	fi
fi

# Set memory variables if not already set, falling back to MEMORYSIZE if needed
INIT_MEMORY=${INIT_MEMORY:-${MEMORY:-${MEMORYSIZE:-1G}}}
MAX_MEMORY=${MAX_MEMORY:-${MEMORY:-${MEMORYSIZE:-1G}}}

export HOME=/home/$DOCKER_USER
exec gosu $DOCKER_USER:$DOCKER_GROUP java -Xms$INIT_MEMORY -Xmx$MAX_MEMORY $JAVAFLAGS -jar /opt/minecraft/paperspigot.jar $PAPERMC_FLAGS nogui
