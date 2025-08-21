# ---------- builder: run Paperclip ONCE with lots of RAM ----------
FROM eclipse-temurin:11-jdk-jammy AS builder
WORKDIR /build
RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*

# Grab the Eaglercraft Paper 1.12.2 template
RUN curl -L -o server.zip \
  https://codeload.github.com/Eaglercraft-Templates/Eaglercraft-Server-Paper/zip/refs/heads/main \
 && unzip server.zip \
 && mv Eaglercraft-Server-Paper-main/* . \
 && rm -rf Eaglercraft-Server-Paper-main server.zip

# Accept EULA so Paperclip can run
RUN echo "eula=true" > eula.txt

# Patch/download libraries WITHOUT starting the server
# (Generates cache/patched_*.jar and downloads libs)
RUN java -Xmx2G -Dpaperclip.patchonly=true -jar paper-1.12.2.jar || true

# Make a clean bundle we can copy into the runtime image
RUN mkdir -p /out && \
    cp -r . /out && \
    cp cache/patched_*.jar /out/paper.jar
# optional: drop the original launcher to avoid accidental use
RUN rm -f /out/paper-1.12.2.jar

# ---------- runtime: tiny, only runs the patched jar ----------
FROM eclipse-temurin:11-jre-jammy
WORKDIR /srv/eagler
COPY --from=builder /out/ ./

# Ensure we bind correctly in Koyeb and respect its $PORT
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Koyeb will route HTTP/WSS -> $PORT; we default to 25565 locally
EXPOSE 25565
ENV JAVA_OPTS="-Xms256m -Xmx384m"
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["java", "-server", "-jar", "paper.jar", "nogui"]
