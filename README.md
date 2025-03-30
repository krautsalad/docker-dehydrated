# docker-dehydrated

Cron-Managed Certificate Renewal with Dehydrated.

**docker-dehydrated** is an Alpine-based Docker container that periodically runs the [dehydrated client](https://github.com/dehydrated-io/dehydrated) using cron. It automates certificate renewals via Let's Encrypt, providing a simple and efficient solution for managing SSL certificates.

## Configuration

### Docker Compose Example

```yaml
# docker-compose.yml
services:
  dehydrated:
    container_name: dehydrated
    depends_on:
      - nginx
    environment:
      CONTACT_EMAIL: noreply@example.com
      SCHEDULE: 0 3 * * *
      TZ: Europe/Berlin
    image: krautsalad/dehydrated
    # needed to run hooks on host
    pid: host
    privileged: true
    restart: unless-stopped
    volumes:
       - ./config/dehydrated:/var/lib/dehydrated/config:ro
       - ./data/acme-challenge:/var/lib/dehydrated/acme-challenge
       - ./data/dehydrated:/var/lib/dehydrated/data
       - ./data/ssl:/var/lib/dehydrated/ssl
       - /:/host
```

### Environment Variables

- `CONTACT_EMAIL`: E-mail address for your Let's Encrypt account (default: empty).
- `SCHEDULE`: Cron schedule for running dehydrated (default: `0 0 * * *`).
- `TZ`: Timezone setting (default: UTC).

### Dependent container

A web server is required to deliver the requested ACME challenge when dehydrated creates or renews certificates. For example, you can use an Nginx container. Below is a minimal sample using Docker Compose:

```yml
# docker-compose.yml
services:
  nginx:
    container_name: nginx
    image: krautsalad/nginx
    restart: unless-stopped
    volumes:
      - ./data/acme-challenge:/etc/nginx/acme-challenge:ro
```

See also [krautsalad/nginx](https://hub.docker.com/r/krautsalad/nginx) for more information on configuring the Nginx container.

## How it works

At runtime, the container's cron job executes the command:

```sh
dehydrated -c -g
```

This command checks for certificate renewals and generates new certificates for all configured domains.

### Initial Setup

#### Domains File

Create a file at `./config/dehydrated/domains.txt` listing all the domains for which you want to obtain certificates. For example:

```txt
server1.example.com
server2.example.com
```

#### Hook Script

Create a hook script at `./config/dehydrated/hook.sh`. This script defines the actions to perform after a certificate has been renewed. For instance, the following example copies common certificate files to your `./data/ssl` mount and reloads Nginx:

```sh
#!/usr/bin/env bash

SSLDIR=/var/lib/dehydrated/ssl

deploy_cert() {
  local DOMAIN="${1}" KEYFILE="${2}" CERTFILE="${3}" FULLCHAINFILE="${4}" CHAINFILE="${5}" TIMESTAMP="${6}"

  cp -f "$KEYFILE" "$SSLDIR/$DOMAIN.key"
  cp -f "$CERTFILE" "$SSLDIR/$DOMAIN.crt"
  cp -f "$FULLCHAINFILE" "$SSLDIR/$DOMAIN.pem"
  cp -f "$CHAINFILE" "$SSLDIR/$DOMAIN.ca"
  cat "$KEYFILE" "$FULLCHAINFILE" > "$SSLDIR/$DOMAIN.pem.key"

  chmod go+r "$SSLDIR/$DOMAIN.ca" "$SSLDIR/$DOMAIN.crt" "$SSLDIR/$DOMAIN.pem" 
  chroot /host docker exec nginx /usr/sbin/nginx -s reload
}

HANDLER="$1"; shift
if [[ "${HANDLER}" =~ ^(deploy_cert)$ ]]; then
  "$HANDLER" "$@"
fi
```

Make sure to mark the script as executable (`chmod +x ./config/dehydrated/hook.sh`).

## Source Code

You can find the full source code on [GitHub](https://github.com/krautsalad/docker-dehydrated).
