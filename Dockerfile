FROM bcit/alpine:3.9
# vim: syntax=dockerfile

LABEL maintainer="David_Goodwin@bcit.ca, Juraj Ontkanin"
LABEL version="2.02"

ENV VERSION "2.02"
ENV CONFIGDIR /config

ENV PROG postfwd2
ENV ADDRESS 0.0.0.0
ENV PORT 10040
ENV CACHE 60
ENV EXTRA "--summary=600 --noidlestats"
ENV CONF postfwd.cf

ENV ETC /etc/postfwd
ENV TARGET /usr
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

WORKDIR /tmp/

RUN wget https://postfwd.org/postfwd-${VERSION}.tar.gz \
 && tar -xvf postfwd-${VERSION}.tar.gz \
 && cp postfwd/sbin/* ${TARGET}/sbin/ \
 && mkdir /etc/postfwd \
 && cp postfwd/etc/* /etc/postfwd/ \
 && mkdir /usr/bin/postfwd-docker \
 && cp postfwd/docker/postfwd-docker.sh /usr/bin/postfwd-docker

RUN rm -rf /tmp/*

WORKDIR /

RUN addgroup -g ${GID} ${GROUP} \
 && adduser -u ${UID} -D -H -G ${GROUP} -h ${HOME} -s /bin/false ${USER} \
 && mkdir -p ${ETC} ${HOME} \
 && chown -R root:${GID} ${ETC} \
 && chmod 0750 ${ETC} \
 && chmod 0640 ${ETC}/* \
 && chown -R ${UID}:${GID} ${HOME} \
 && chmod -R 0700 ${HOME} \
 && chown root:root ${TARGET}/sbin/postfwd* /usr/bin/postfwd-docker \
 && chmod 0755 ${TARGET}/sbin/postfwd* /usr/bin/postfwd-docker

RUN mkdir /config
COPY 50-copy-postfwd-config.sh docker-entrypoint.d/ 

EXPOSE ${PORT}

CMD ${TARGET}/sbin/${PROG} --file=${ETC}/${CONF} --user=${USER} --group=${GROUP} \
    --server_socket=tcp:${ADDRESS}:${PORT} --cache_socket=unix::${HOME}/postfwd.cache \
  	--pidfile=${HOME}/postfwd.pid --save_rates=${HOME}/postfwd.rates --save_groups=${HOME}/postfwd.groups \
  	--cache=${CACHE} ${EXTRA} \
  	--stdout --nodaemon
