FROM nginx:mainline-alpine
EXPOSE 80
COPY --from=ghcr.io/fivexl/lprobe:0.0.7 /lprobe /bin/lprobe
COPY ./default.conf /etc/nginx/conf.d/default.conf
COPY ./index.html /usr/share/nginx/html/index.html
ADD --chmod=644 https://img.freepik.com/free-vector/simple-vibing-cat-square-meme_742173-4493.jpg /usr/share/nginx/html/cat.jpg