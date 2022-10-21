#!/bin/sh

echo "KIBANA_PROXY_AUTH_HEADER=\"$(echo -n ${KIBANA_PROXY_USER}:${KIBANA_PROXY_PASSWORD} | base64)\"" > /etc/caddy/caddy.env

exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile --envfile /etc/caddy/caddy.env