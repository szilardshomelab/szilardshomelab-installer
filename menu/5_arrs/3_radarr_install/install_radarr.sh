#!/bin/bash

# Prompt the user to confirm installation
while true; do
    read -p "Are you sure you want to install Radarr? (y/n): " CONFIRM
    case "$CONFIRM" in
        [yY]* ) break;;   # If 'y' or 'Y' is input, proceed
        [nN]* ) echo "Installation aborted."; exit 1;;  # If 'n' or 'N' is input, exit
        * ) echo "Please choose 'y' or 'n'."; # If not 'y' or 'n', prompt again
    esac
done

ENV_FILE="/opt/appdata/.network.env"
TEMPLATE_FILE="/opt/szilardshomelab/appdata/radarr/compose-template.yml"
mkdir -p /opt/appdata/radarr
touch /opt/appdata/radarr/compose.yml
OUTPUT_FILE="/opt/appdata/radarr/compose.yml"

# Load environment variables from the .env file
export $(grep -v '^#' $ENV_FILE | xargs)

# Substitute variables in the template and generate the docker-compose.yml
sed "s/__DOCKER_NETWORK_NAME__/${DOCKER_NETWORK_NAME}/g" $TEMPLATE_FILE > $OUTPUT_FILE

# Start Docker Compose services
sudo docker compose -f $OUTPUT_FILE --env-file /opt/appdata/.env up -d

# Check if the Docker Compose command was successful
if [[ $? -ne 0 ]]; then
  echo "Error: Failed to start radarr service"
  exit 1
fi

echo "radarr service started successfully"

# Get the server's IP address
SERVER_IP=$(hostname -I | awk '{print $1}')

# Assuming Portainer is exposed on port 7878
radarr_PORT=7878

# Construct the access URL
ACCESS_URL="http://$SERVER_IP:$radarr_PORT"

echo "Access radarr at: $ACCESS_URL"
