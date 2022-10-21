ARG CADDY_VERSION

FROM caddy:${CADDY_VERSION}-builder-alpine AS builder

RUN xcaddy build \
    --with github.com/greenpau/caddy-security

FROM caddy:${CADDY_VERSION}-alpine

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
COPY entrypoint.sh .
COPY assets /srv/assets 

ENTRYPOINT [ "./entrypoint.sh" ]