# 
# Small helper to start container with different runtime args 
# 
# Usage: ./start-container.sh 

# process name: posftfwd1, postfwd2, postfwd3
PROG=postfwd1

# port for postfwd
PORT=10050

# request cache in seconds. use '0' to disable
CACHE=60

# additional arguments, see postfwd -h or man page for more
EXTRA="--summary=600"

# name of container used when building
CONTAINER_NAME="postfwd:bcit"
 
docker run -it -e PROG=$PROG -e PORT=$PORT -e CACHE=$CACHE -e EXTRA=${EXTRA[@]} -t $CONTAINER_NAME
