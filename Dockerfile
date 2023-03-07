FROM alpine:latest as builder
LABEL maintainer "Slurdge <slurdge@slurdge.org>"

ARG platform="linux"
ARG TARGETPLATFORM

RUN apk add --no-cache openssh-client openssl ca-certificates git wget

# install caddy
RUN set -eux; \
    apkArch="$(apk --print-arch)"; \
    echo "$apkArch"; \
    case "$apkArch" in \
        x86_64)  arch='amd64'; armv='';; \
        armhf)   arch='arm'; armv='6';; \
        armv7)   arch='arm'; armv='7';; \
        aarch64) arch='arm64'; armv='';; \
        ppc64el) arch='ppc64'; armv='';; \
        ppc64le) arch='ppc64le'; armv='';; \
        s390x)   arch='s390x'; armv='';; \
        *) echo >&2 "error: unsupported architecture ($arch)"; exit 1 ;;\
    esac; \
    wget --quiet "https://caddyserver.com/api/download?os=$platform&arch=$arch&arm=$armv&p=github.com%2Fmholt%2Fcaddy-webdav" -O caddy

# get keeweb release
RUN git clone --depth=1 --branch "gh-pages" https://github.com/keeweb/keeweb/
RUN sed -i "s/(no-config)/config.json/" keeweb/index.html
RUN sed -i 's|pattern:"^https://.+"|pattern:"(^https://.+)\|(.+\\.kdbx$)"|' keeweb/index.html
RUN sha512=`sed -n 's|.*><script>\(.*\)</script>.*|\1|p' keeweb/index.html | openssl sha512 -binary | openssl base64 -A` && sed -i "s|script-src 'sha512\-[^']*'|script-src 'sha512-$sha512'|" keeweb/index.html

FROM alpine:latest

EXPOSE 8080
WORKDIR /srv

COPY Caddyfile /etc/Caddyfile
COPY config.json /srv/
COPY --from=builder keeweb/ /srv/
COPY --from=builder caddy /usr/bin/caddy

# validate install
RUN mkdir /srv/dav/ && chmod +x /usr/bin/caddy && /usr/bin/caddy version && /usr/bin/caddy list-modules

ENTRYPOINT ["caddy"]
CMD ["run", "--config", "/etc/Caddyfile"]

