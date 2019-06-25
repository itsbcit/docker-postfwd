# Modified from: https://github.com/postfwd/postfwd/tree/master/docker 
#
#   To rebuild:
#
#	docker build --no-cache . -f Dockerfile -t postfwd:bcit
#
# See start-container.sh for wayto override default runtime variables 

FROM bcit/alpine

LABEL maintainer="David Goodwin - David_Goodwin@bcit.ca"

##
## RUNTIME ARGS
##
# use 'postfwd1' or 'postfwd2' to switch between versions
# go to http://postfwd.org/versions.html for more info
ENV PROG=postfwd1
# port for postfwd
ENV PORT=10040
# request cache in seconds. use '0' to disable
ENV CACHE=60
# additional arguments, see postfwd -h or man page for more
ENV EXTRA="--summary=600 --noidlestats"
# get config file from ARG
ENV CONF=postfwd.cf 

##
## CONTAINER ARGS
##

# configuration directory
ENV ETC=/etc/postfwd
# target for postfwd distribution
ENV TARGET=/usr
# data directory
ENV HOME=/var/lib/postfwd
# user and group for execution
ENV USER=postfw 
ENV GROUP=postfw
ENV UID=110
ENV GID=110

# Change working directory 
WORKDIR /tmp/

# Pull latest postfwd version from site and extract
RUN wget https://postfwd.org/postfwd-latest.tar.gz -O postfwd-latest.tar.gz
RUN tar -xvf postfwd-latest.tar.gz

# Copy executables and default config 
RUN cp postfwd/sbin/* ${TARGET}/sbin/
RUN mkdir /etc/postfwd && cp postfwd/etc/* /etc/postfwd/
RUN mkdir /usr/bin/postfwd-docker && cp postfwd/docker/postfwd-docker.sh /usr/bin/postfwd-docker

# Cleanup 
RUN rm -rf /tmp/*

# Change working directory back 
WORKDIR /

# install stuff
RUN apk update && apk add \
	perl \
	perl-net-dns \
	perl-net-server \
	perl-netaddr-ip \
	perl-net-cidr-lite \
	perl-time-hires \
	perl-io-multiplex 

# create stuff
RUN addgroup -g ${GID} ${GROUP}
RUN adduser -u ${UID} -D -H -G ${GROUP} -h ${HOME} -s /bin/false ${USER}
RUN mkdir -p ${ETC} ${HOME}

# For external postfwd.cf file 
COPY 50-copy-postfwd-config.sh docker-entrypoint.d/ 

# set ownership & permissions
RUN chown -R root:${GID} ${ETC} && chmod 0750 ${ETC} && chmod 0640 ${ETC}/*
RUN chown -R ${UID}:${GID} ${HOME} && chmod -R 0700 ${HOME}
RUN chown root:root ${TARGET}/sbin/postfwd* /usr/bin/postfwd-docker && chmod 0755 ${TARGET}/sbin/postfwd* /usr/bin/postfwd-docker

# open port
EXPOSE ${PORT}

# start postfwd - don't worry about versions: postfwd1 will silently ignore postfwd2-specific arguments 
CMD ${TARGET}/sbin/${PROG} --file=${ETC}/${CONF} --user=${USER} --group=${GROUP} \
	--server_socket=tcp:0.0.0.0:${PORT} --cache_socket=unix::${HOME}/postfwd.cache \
	--pidfile=${HOME}/postfwd.pid --save_rates=${HOME}/postfwd.rates --save_groups=${HOME}/postfwd.groups \
	--cache=${CACHE} ${EXTRA} \
	--stdout --nodaemon