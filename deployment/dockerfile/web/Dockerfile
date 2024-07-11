FROM nginx:mainline-alpine
EXPOSE 80
COPY --from=ghcr.io/fivexl/lprobe:0.0.7 /lprobe /bin/lprobe
COPY ./default.conf /etc/nginx/conf.d/default.conf
COPY ./index.html /usr/share/nginx/html/index.html