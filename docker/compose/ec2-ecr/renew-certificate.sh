#!/usr/bin/env bash
set -euo pipefail
cd /home/ec2-user/brandhub/ecr
docker run --rm -v "$PWD/letsencrypt:/etc/letsencrypt" -v "$PWD/acme-webroot:/var/www/certbot" certbot/certbot renew --quiet
docker compose -f backend.compose.json exec -T nginx nginx -t
docker compose -f backend.compose.json exec -T nginx nginx -s reload
