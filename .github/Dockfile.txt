FROM catthehacker/ubuntu:act-latest
RUN apt-get update && apt-get install -y powershell && apt-get clean
