
# create container and mount working directory
docker run -dit --name stheno-build -v "$PWD":/work -w /work swift:latest bash

# build library in relase configuration
docker exec -it stheno-build bash -lc "swift build -c release"

# copy built library to host machine
docker cp stheno-build:/work/.build/release/libStheno.a ~/Downloads/

# cleann up
docker stop stheno-build
docker rm stheno-build
