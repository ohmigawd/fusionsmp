#!/bin/sh
set -e
# Map Koyeb's $PORT (if present) into server.properties
if [ -n "$PORT" ]; then
  if grep -q "^server-port=" server.properties 2>/dev/null; then
    sed -i "s/^server-port=.*/server-port=${PORT}/" server.properties
  else
    echo "server-port=${PORT}" >> server.properties
  fi
fi
exec ${JAVA_OPTS:+sh -c "exec $* $JAVA_OPTS"} "$@"
