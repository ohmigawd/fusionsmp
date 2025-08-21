#!/bin/sh
set -e

# Map Koyeb's $PORT into server.properties
if [ -n "$PORT" ]; then
  if grep -q "^server-port=" server.properties 2>/dev/null; then
    sed -i "s/^server-port=.*/server-port=${PORT}/" server.properties
  else
    echo "server-port=${PORT}" >> server.properties
  fi
  # Make sure we bind on all interfaces just in case
  if grep -q "^server-ip=" server.properties 2>/dev/null; then
    sed -i "s/^server-ip=.*/server-ip=0.0.0.0/" server.properties
  else
    echo "server-ip=0.0.0.0" >> server.properties
  fi
fi

# Run Java with JVM flags BEFORE -jar, pass any server args (e.g., nogui)
exec java -server -jar paper.jar "$@"
