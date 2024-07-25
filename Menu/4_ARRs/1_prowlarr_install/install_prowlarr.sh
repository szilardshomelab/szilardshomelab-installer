#!/bin/bash

# Prompt the user to confirm installation
while true; do
    read -p "Are you sure you want to install Prowlarr? (y/n): " CONFIRM
    case "$CONFIRM" in
        [yY]* ) break;;   # If 'y' or 'Y' is input, proceed
        [nN]* ) echo "Installation aborted."; exit 1;;  # If 'n' or 'N' is input, exit
        * ) echo "Please choose 'y' or 'n'."; # If not 'y' or 'n', prompt again
    esac
done

# Update the .env file
ENV_FILE="/opt/szilardshomelab/.env"

# Check if the entry already exists
if grep -q '^SMB=' "$ENV_FILE"; then
    sudo sed -i "s/^SMB=.*/SMB=$SMB_PATH/" "$ENV_FILE"
else
    echo "SMB=$SMB_PATH" | sudo tee -a "$ENV_FILE" > /dev/null
fi

TEMPLATE_FILE="/opt/szilardshomelab/appdata/prowlarr/compose-template.yml"
OUTPUT_FILE="/opt/szilardshomelab/appdata/prowlarr/compose.yml"

# Load environment variables from the .env file
export $(grep -v '^#' $ENV_FILE | xargs)

# Substitute variables in the template and generate the docker-compose.yml
envsubst < $TEMPLATE_FILE > $OUTPUT_FILE

# Run the Docker Compose command with the environment files
echo "Starting the prowlarr service..."
sudo docker compose -f $OUTPUT_FILE up -d

# Check if the Docker Compose command was successful
if [[ $? -ne 0 ]]; then
  echo "Error: Failed to start prowlarr service"
  exit 1
fi

echo "prowlarr service started successfully"

# Get the server's IP address
SERVER_IP=$(hostname -I | awk '{print $1}')

# Assuming Portainer is exposed on port 9696
prowlarr_PORT=9696

# Construct the access URL
ACCESS_URL="http://$SERVER_IP:$prowlarr_PORT"

echo "Access prowlarr at: $ACCESS_URL"