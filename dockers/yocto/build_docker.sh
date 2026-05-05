# Generate docker name (must be all lowercase)
dockerName=yocto-build-${USER}
dockerName=$(echo "$dockerName" | tr '[:upper:]' '[:lower:]')

# Build the docker
docker image build . -t \
   $dockerName:latest \
   --build-arg user=${USER} \
   --build-arg uid="$(id -u)" \
   --build-arg gid="$(id -g)"
