#!/bin/bash

# Define source and target directories
sourcedir="/var/lib/docker/volumes"
targetdir="/home/$USER/docker_backup"
datetime=$(date +"%Y-%m-%d_%H-%M-%S")
keepbackup=10
filename="$datetime-backup.tar.gz"

# Function to print messages with formatting
print_message() {
    echo -e "\e[1;32m$1\e[0m"  # Display messages in green color
}

# Check if target directory exists, if not, create it
if [ ! -d "$targetdir" ]; then
    print_message "Creating target directory: $targetdir"
    mkdir -p "$targetdir"
fi

# Display a warning and prompt for confirmation
echo -e "\e[1;31mWARNING: All containers will be stopped.\e[0m"
read -p "Do you want to proceed? (y/n): " response

if [[ ! $response =~ ^[Yy]$ ]]; then
    print_message "Script aborted."
    exit 1
fi

# Stop Docker containers
print_message "Stopping Docker containers..."
container_ids=$(docker ps -q)
for container_id in $container_ids; do
    docker stop $container_id
done

# Create a tarball of the Docker volumes
print_message "Creating backup..."
sudo tar -czvf "$targetdir/$filename" -C "$sourcedir" .

# Start Docker containers
print_message "Starting Docker containers..."
for container_id in $container_ids; do
    docker start $container_id
done

# Delete backups older than $keepbackup days
# Uncomment the following line if you want to delete old backups
# find "$targetdir" -type f -name '*.tar.gz' -mtime +$keepbackup -exec rm {} \;

print_message "Backup completed successfully."
