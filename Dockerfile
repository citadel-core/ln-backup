FROM debian:bullseye-slim

COPY . /backup-manager

CMD [ "bash", "/backup-manager/start.sh" ]
