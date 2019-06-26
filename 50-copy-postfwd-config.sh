TEMP_CONFFILE=/config/postfwd.cf
[ -f "$TEMP_CONFFILE" ] && { cp $TEMP_CONFFILE ${ETC}/${CONF};chown -R root:${GID} ${ETC}/${CONF};chmod 0640 ${ETC}/${CONF};echo "copied custom: $TEMP_CONFFILE"; } \
	|| echo "using default: ${ETC}/${CONF}"
