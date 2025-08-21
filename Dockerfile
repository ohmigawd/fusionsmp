FROM eclipse-temurin:17-jre-jammy
WORKDIR /srv/eagler

# deps
RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*

# grab the universal Eaglercraft server template (Paper 1.12.2 + plugins)
RUN curl -L -o server.zip \
  https://codeload.github.com/Eaglercraft-Templates/Eaglercraft-Server-Paper/zip/refs/heads/main \
 && unzip server.zip \
 && mv Eaglercraft-Server-Paper-main/* . \
 && rm -rf Eaglercraft-Server-Paper-main server.zip

# accept EULA and make sure we bind on all interfaces
RUN echo "eula=true" > eula.txt \
 && (sed -i 's/^server-ip=.*/server-ip=0.0.0.0/' server.properties || true)

# map Koyeb $PORT to server.properties on container start (if Koyeb sets one)
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 25565
ENV JAVA_OPTS="-Xmx384m"
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["java", "-server", "-XX:+UseG1GC", "-XX:MaxGCPauseMillis=150", "-jar", "paper-1.12.2.jar", "nogui"]
