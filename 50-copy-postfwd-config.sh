cp --dereference -r "$CONFIGDIR"/* /etc/postfwd/

if [ -f "$CONFIGDIR"/.DOCKERIZE.env ]; then
    echo "loading: ${CONFIGDIR}/.DOCKERIZE.env"
    . "$CONFIGDIR"/.DOCKERIZE.env
fi
echo "DOCKERIZE_ENV: ${DOCKERIZE_ENV}"
for tmpl_file in $( find /etc/postfwd -type f -name '*.tmpl' -not -path '*/\.git/*' ); do
    config_file="$( dirname -- "$tmpl_file" )/$( basename -- "$tmpl_file" .tmpl )"
    echo "dockerizing: ${tmpl_file}"
    echo "         =>  ${config_file}"
    dockerize -template "$tmpl_file":"$config_file" \
    && rm -f "$tmpl_file"
done

chown -R root:${GID} /etc/postfwd/*
chmod 0640 /etc/postfwd/*
