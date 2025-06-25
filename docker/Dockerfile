FROM alpine AS build

ENV VERSION=0.7.2

RUN wget -q https://github.com/dehydrated-io/dehydrated/releases/download/v${VERSION}/dehydrated-${VERSION}.tar.gz && \
    mkdir -p /dehydrated && \
    tar -xzf dehydrated-${VERSION}.tar.gz --strip-components=1 -C /dehydrated

FROM alpine

RUN apk update && \
    apk add --no-cache bash busybox-suid curl openssh-client-default openssl tzdata && \
    rm -rf /root/.cache /tmp/* /var/cache/apk/* /var/tmp/*

RUN rm -rf /var/spool/cron/crontabs && \
    mkdir -p /var/spool/cron/crontabs && \
    cat <<EOF > /var/spool/cron/crontabs/root
0 0 * * * /usr/bin/dehydrated -c -g >> /var/log/cron/cron.log 2>&1
EOF

COPY --from=build /dehydrated/dehydrated /usr/bin/dehydrated
COPY dehydrated/config /etc/dehydrated/config
COPY docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["crond", "-f"]
