TEMP_CONFFILE=/config/postfwd.cf
[ -f "$TEMP_CONFFILE" ] && { cp $TEMP_CONFFILE ${ETC}/${CONF}; echo "copied custom: $TEMP_CONFFILE"; } \
	|| echo "using default: ${ETC}/${CONF}"