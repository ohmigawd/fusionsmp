#!/bin/sh
set -e

# 1) First boot: seed /data from baked dist
if [ -z "$(ls -A /data 2>/dev/null)" ]; then
  cp -a /opt/eagler-dist/. /data/
fi

# 2) Ensure Eaglercraft friendliness + bind/port
if grep -q "^online-mode=" /data/server.properties 2>/dev/null; then
  sed -i "s/^online-mode=.*/online-mode=false/" /data/server.properties
else
  echo "online-mode=false" >> /data/server.properties
fi

# Zeabur injects PORT; listen on it (fallback 25565 locally)
PORT="${PORT:-25565}"
if grep -q "^server-port=" /data/server.properties 2>/dev/null; then
  sed -i "s/^server-port=.*/server-port=${PORT}/" /data/server.properties
else
  echo "server-port=${PORT}" >> /data/server.properties
fi
if grep -q "^server-ip=" /data/server.properties 2>/dev/null; then
  sed -i "s/^server-ip=.*/server-ip=0.0.0.0/" /data/server.properties
else
  echo "server-ip=0.0.0.0" >> /data/server.properties
fi

# 3) Run server
exec java -server -jar /data/paper.jar "$@"
