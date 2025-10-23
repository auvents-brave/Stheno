docker run -dit --name stheno-build -v "$PWD":/work -w /work swift:latest bash
docker exec -it stheno-build bash -lc "swift build -c release"
docker cp stheno-build:/work/.build/release/libStheno.a ~/Downloads/
# docker stop stheno-build && docker rm stheno-build
edited
