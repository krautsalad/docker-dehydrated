#!/bin/sh
set -e
mkdir -p /var/lib/dehydrated/acme-challenge /var/lib/dehydrated/config /var/lib/dehydrated/data/accounts /var/lib/dehydrated/data/certs /var/lib/dehydrated/data/chains /var/lib/dehydrated/ssl /var/log/cron
ln -sf /proc/1/fd/1 /var/log/cron/cron.log
[ -n "$CONTACT_EMAIL" ] && sed -i "s|^CONTACT_EMAIL=.*|CONTACT_EMAIL=\"$CONTACT_EMAIL\"|" /etc/dehydrated/config
exec "$@"
