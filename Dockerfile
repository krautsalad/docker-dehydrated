FROM alpine

RUN apk update && \
    apk add --no-cache bash busybox-suid curl openssh-client-default openssl tzdata && \
    apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing dehydrated && \
    rm -rf /etc/dehydrated /root/.cache /tmp/* /var/cache/apk/* /var/tmp/*

RUN rm -rf /var/spool/cron/crontabs && \
    mkdir -p /var/spool/cron/crontabs && \
    cat <<EOF > /var/spool/cron/crontabs/root
0 0 * * * /usr/bin/dehydrated -c -g >> /var/log/cron/cron.log 2>&1
EOF

COPY dehydrated/config /etc/dehydrated/config
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["crond", "-f"]
