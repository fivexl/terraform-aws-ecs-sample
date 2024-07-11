FROM caddy:alpine
EXPOSE 80
COPY --from=ghcr.io/fivexl/lprobe:0.0.7 /lprobe /bin/lprobe
COPY ./index.html /usr/share/caddy/index.html
COPY ./Caddyfile /etc/caddy/Caddyfile
ADD --chmod=644 https://img.freepik.com/free-vector/simple-vibing-cat-square-meme_742173-4493.jpg /usr/share/caddy/cat.jpg