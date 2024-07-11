FROM caddy:alpine
EXPOSE 80
COPY --from=ghcr.io/fivexl/lprobe:0.0.7 /lprobe /bin/lprobe
COPY ./index.html /usr/share/caddy/index.html
COPY ./Caddyfile /etc/caddy/Caddyfile
ADD --chmod=644 https://img.freepik.com/free-vector/illustration-business-compliance_53876-9186.jpg /usr/share/caddy/dog.jpg