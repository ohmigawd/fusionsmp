# ---------- builder: patch Paper once ----------
FROM eclipse-temurin:17-jdk-jammy AS builder
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

# Patch/download libs WITHOUT starting the server (generates cache/patched_*.jar)
RUN java -Xmx2G -Dpaperclip.patchonly=true -jar paper-1.12.2.jar || true

# Bundle a clean dist and the patched jar
RUN mkdir -p /out && cp -r . /out && cp cache/patched_*.jar /out/paper.jar && rm -f /out/paper-1.12.2.jar

# ---------- runtime: lean image, run the patched jar ----------
FROM eclipse-temurin:17-jre-jammy
# Keep the built server in the image here
COPY --from=builder /out/ /opt/eagler-dist/

# We'll run from /data (easy to mount a Volume later)
WORKDIR /data

# Small heap; tweak if you have more memory
ENV JAVA_TOOL_OPTIONS="-Xms256m -Xmx384m -DPaper.IgnoreJavaVersion=true"

# Entrypoint seeds /data, maps Zeabur's $PORT into server.properties, then runs Paper
COPY docker-entrypoint.sh /usr/local/bin/entry.sh
RUN chmod +x /usr/local/bin/entry.sh

EXPOSE 25565
ENTRYPOINT ["/usr/local/bin/entry.sh"]
CMD ["nogui"]
