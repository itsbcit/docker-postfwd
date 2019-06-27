FROM bcit/alpine:3.9
# vim: syntax=dockerfile

LABEL maintainer="David_Goodwin@bcit.ca, Juraj Ontkanin"
LABEL version="2.02"

ENV CONFIGDIR /config

ENV PROG postfwd2
ENV ADDRESS 0.0.0.0
ENV PORT 10040
ENV CACHE 60
ENV EXTRA "--summary=600 --noidlestats"
ENV CONF postfwd.cf

ENV HOME /var/lib/postfwd
ENV USER postfw 
ENV GROUP postfw
ENV UID 110
ENV GID 110

RUN apk update && apk add \
    perl \
    perl-net-dns \
    perl-net-server \
    perl-netaddr-ip \
    perl-net-cidr-lite \
    perl-time-hires \
    perl-io-multiplex 

RUN mkdir "$CONFIGDIR"

WORKDIR /tmp/

RUN wget https://postfwd.org/postfwd-2.02.tar.gz \
 && tar -xvf postfwd-2.02.tar.gz \
 && cp postfwd/sbin/* /usr/sbin/ \
 && mkdir /etc/postfwd \
 && cp postfwd/etc/* "${CONFIGDIR}" \
 && mkdir /usr/bin/postfwd-docker \
 && cp postfwd/docker/postfwd-docker.sh /usr/bin/postfwd-docker

RUN rm -rf /tmp/*

WORKDIR /

RUN addgroup -g ${GID} ${GROUP} \
 && adduser -u ${UID} -D -H -G ${GROUP} -h "${HOME}" -s /bin/false ${USER} \
 && mkdir -p /etc/postfwd "${HOME}" \
 && chown -R root:${GID} /etc/postfwd \
 && chmod 0750 /etc/postfwd \
 && chown -R ${UID}:${GID} "${HOME}" \
 && chmod -R 0700 "${HOME}" \
 && chown root:root /usr/sbin/postfwd* /usr/bin/postfwd-docker \
 && chmod 0755 /usr/sbin/postfwd* /usr/bin/postfwd-docker

COPY 50-copy-postfwd-config.sh docker-entrypoint.d/ 

EXPOSE ${PORT}

CMD /usr/sbin/${PROG} --file="/etc/postfwd/${CONF}" \
    --user=${USER} --group=${GROUP} \
    --server_socket=tcp:${ADDRESS}:${PORT} \
    --cache_socket="unix::${HOME}/postfwd.cache" \
    --cache=${CACHE} \
    --save_rates="${HOME}/postfwd.rates" \
    --save_groups="${HOME}/postfwd.groups" \
    --pidfile="${HOME}/postfwd.pid" \
    --stdout --nodaemon \
    ${EXTRA}
