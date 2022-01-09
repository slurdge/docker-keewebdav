# A docker solution for Keeweb+WebDav

A Docker repository to have a simple Caddy+Keeweb+Webdav solution.

The focus of this repository is **simplicity** so you can roll your own auto hosted Keeweb and Webdav solution.

You can use Keepass synchronisation with the following url:
```https://example.com/database.kdbx```

## Technical stack

Pretty simple:

* [Caddy](https://caddyserver.com/) in http mode with webdav extension;
* [Keeweb](https://keeweb.info/) with a special config removing unused options by default.

Caddy is configured to serve all files ending in `.kdbx` through webdav without authentication, for ease of use.

## Trial run in docker

⚠ **This will not be secured by `https`!** ⚠

```docker run -p 8080:8080 slurdge/keewebdav```

## Run in docker-compose with a traefik load balancer (https)

You can use the following `docker-compose.yml` file with traefik v2:

```yaml
version: '2'
services:
  keeweb:
    image: slurdge/keewebdav:latest
    container_name: keeweb
    restart: always
    volumes:
      - ./data:/srv/dav
    labels:
      - "traefik.http.routers.keeweb.rule=Host(`example.com`)"
      - "traefik.http.routers.keeweb.tls.certresolver=le"
    networks:
      - proxy

networks:
  proxy:
    external: true
```

You can use the following `docker-compose.yml` file with traefik v1:

```yaml
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
      - "traefik.frontend.rule=Host:example.com"
      - "traefik.docker.network=proxy"
    networks:
      - proxy

networks:
  proxy:
    external: true
```

Both examples supposes that there is a network named 'proxy' that is used by traefik.

## Extensions

It's pretty easy to add http-auth to caddy and even https. Please send PR if you want this functionality included.
