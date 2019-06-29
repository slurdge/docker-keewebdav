FROM alpine:latest as builder
LABEL maintainer "Slurdge <slurdge@slurdge.org>"

ARG cversion="1.0.0"
ARG kversion="v1.8.2"
ARG platform="linux"
ARG arch="amd64"

RUN apk add --no-cache openssh-client ca-certificates git wget

# install caddy
RUN wget "https://caddyserver.com/download/$platform/$arch?plugins=http.realip,http.cors,http.minify,http.webdav&license=personal&telemetry=off" -O tmp.tar.gz && tar xzf tmp.tar.gz && rm tmp.tar.gz

# get keeweb release
RUN git clone --depth=1 --branch "gh-pages" https://github.com/keeweb/keeweb/
RUN sed -i "s/(no-config)/config.json/" keeweb/index.html

FROM alpine:latest

EXPOSE 8080
WORKDIR /srv

COPY Caddyfile /etc/Caddyfile
COPY config.json /srv/
COPY --from=builder keeweb/ /srv/
COPY --from=builder caddy /usr/bin/caddy

# validate install
RUN mkdir /srv/dav/ && /usr/bin/caddy -version && /usr/bin/caddy -plugins

ENTRYPOINT ["caddy"]
CMD ["--conf", "/etc/Caddyfile", "--log", "stdout"]

