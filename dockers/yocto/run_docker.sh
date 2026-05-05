# Generate docker name (must be all lowercase)
dockerName=yocto-build-${USER}
dockerName=$(echo "$dockerName" | tr '[:upper:]' '[:lower:]')

# Get home folder location
home=$(echo "$HOME" | sed "s/$USER//")

# Print a warning
echo "This script will expose home directories to the Docker container!"

# Run the docker
docker run -ti \
   --net=host \
   -v /etc/localtime:/etc/localtime:ro \
   -v $home:/home \
   $dockerName:latest /bin/bash
