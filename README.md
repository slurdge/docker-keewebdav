# A docker solution for Keeweb+WebDav

A Docker repository to have a simple Caddy+Keeweb+Webdav solution.

The focus of this repository is **simplicity** so you can roll your own auto hosted Keeweb and Webdav solution.

You can use keepass synchronisation with the following url:
```https://domain.com/database.kdbx``` (you have to use PUT/not secure database write in keepass options)
or
```https://domain.com/kdbx/database.kdbx``` (you can use MOVE/secure database write in keepass options)

## Technical stack

Pretty simple:
* [Caddy](https://caddyserver.com/) in http mode with webdav extension;
* [Keeweb](https://keeweb.info/) with a special config removing unused options by default.

Caddy is configured to serve all files ending in `.kdbx` through webdav without authentication, for ease of use.

## Trial run in docker

⚠ **This will not be secured by `https`!** ⚠

```docker run -p 8080:8080 slurdge/keewebdav```

## Run in docker-compose with a traefik load balancer (https)

You can use the following `docker-compose.yml` file:

```
version: '2'
services:
  keeweb:
    image: slurdge/keewebdav:latest
    container_name: keeweb
    restart: always
    volumes:
      - ./data:/srv/dav
    labels:
      - "traefik.enable=true"
      - "traefik.port=8080"
      - "traefik.frontend.rule=Host:domain.com"
      - "traefik.docker.network=proxy"
    networks:
      - proxy

networks:
  proxy:
    external: true
```

## Extensions

It's pretty easy to add http-auth to caddy and even https. Please send PR if you want this functionality included.
