#!/bin/bash

TXTURE_URL="https://txture.host"  # without trailing slash
API_TOKEN="YOURAPITOKENHERE"
TXTURE_HOME="/path/to/your/txture_home"
TARGET="/target/path/for/your/backup.zip"

# check whether requirements are installed on the system
hash jq 2>/dev/null || { echo >&2 "jq is required for this script.  Aborting."; exit 1; }
hash zip 2>/dev/null || { echo >&2 "zip is required for this script.  Aborting."; exit 1; }

# Enable maintenance mode
echo "Activating maintenance mode..."
curl -X PUT -s\
  $TXTURE_URL'/api/v11/maintenance-mode/enable' \
  -H 'authorization: Bearer '$API_TOKEN \
  -H 'cache-control: no-cache'

# check our own user ID
USERID=$(curl -X GET -s $TXTURE_URL'/api/v11/whoami' -H 'authorization: Bearer '$API_TOKEN -H 'cache-control: no-cache' | jq -r '.id' | tr -d '\n')

# Wait until maintenance mode has been activated
echo "Waiting for maintenance mode..."
for i in {1..10}
do
    MAINTENANCE_ACTIVATED_BY=$(curl -X GET -s $TXTURE_URL'/api/v11/maintenance-mode' -H 'cache-control: no-cache' | jq -r '.enabledByActorDatabaseIds[0]' | tr -d '\n')
    if [ "$MAINTENANCE_ACTIVATED_BY" == "$USERID" ]
    then
        echo "Maintenance mode is active. Starting backup."
        break
    fi

    if [ $i == 10 ]
    then
        echo "Maintenance did not start after 100 seconds. Aborting backup."
        exit 1
    fi
    sleep 10
done

# Ready for backup
zip $TARGET -ruq $TXTURE_HOME
echo "Backup complete."

# Disable maintenance mode
echo "Deactivating maintenance mode..."
curl -X PUT -s\
  $TXTURE_URL'/api/v11/maintenance-mode/disable' \
  -H 'authorization: Bearer '$API_TOKEN \
  -H 'cache-control: no-cache' > /dev/null