FROM node:alpine

WORKDIR /react-docker

# Tools für Sync + Bash
RUN apk add --no-cache bash rsync inotify-tools

# entrypoint reinlegen
COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 3000
ENTRYPOINT ["/bin/bash", "/usr/local/bin/entrypoint.sh"]
