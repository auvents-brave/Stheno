# docker run --rm docker.io/library/ubuntu:questing bash

docker build -f Dockerfile -t steffff/swift:latest .
docker tag steffff/swift:latest swift:latest
docker push steffff/swift:latest

