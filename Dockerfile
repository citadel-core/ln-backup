FROM debian:bullseye-slim

RUN apt update && apt install -y gpg fswatch curl jq && apt clean && rm -rf /var/lib/apt/lists/*

COPY . /backup-manager

WORKDIR /backup-manager

CMD [ "bash", "/backup-manager/start.sh" ]
