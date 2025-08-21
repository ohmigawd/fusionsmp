#!/bin/sh
set -e

# If Koyeb provides $PORT, write it into server.properties so the server listens there.
if [ -n "$PORT" ]; then
  if grep -q "^server-port=" server.properties 2>/dev/null; then
    sed -i "s/^server-port=.*/server-port=${PORT}/" server.properties
  else
    echo "server-port=${PORT}" >> server.properties
  fi
fi

exec "$@"
