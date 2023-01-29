FROM debian:bullseye-slim

COPY . /backup-manager

WORKDIR /backup-manager

CMD [ "bash", "/backup-manager/start.sh" ]
