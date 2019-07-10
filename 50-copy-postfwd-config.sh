cp --dereference -r "$CONFIGDIR"/* /etc/postfwd/

if [ -f "$CONFIGDIR"/.DOCKERIZE.env ]; then
    echo "loading ${CONFIGDIR}/.DOCKERIZE.env environment"
    . "$CONFIGDIR"/.DOCKERIZE.env
fi
for config_file in $( find /etc/postfwd -type f ); do 
    dockerize -template "$config_file":"$config_file"
done

chown -R root:${GID} /etc/postfwd/*
chmod 0640 /etc/postfwd/*
