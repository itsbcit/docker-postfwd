cp --dereference -r "$CONFIGDIR"/* /etc/postfwd/
chown -R root:${GID} /etc/postfwd/*
chmod 0640 /etc/postfwd/*
